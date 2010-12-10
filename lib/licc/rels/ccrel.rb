require 'rubygems'
require 'rdf/raptor'

module Licc
    module License
        class CCREL
            include License
            attr_reader :permits, :requires, :prohibits

            def self.parse(rdf_uri)
                # RDF predicates used by ccREL.
                cc = 'http://creativecommons.org/ns#'
                cc_permits = cc + 'permits'
                cc_requires = cc + 'requires'
                cc_prohibits = cc + 'prohibits'

                dc = 'http://purl.org/dc/elements/1.1/'
                dcq = 'http://purl.org/dc/terms/'

                # Initializing variables that will hold the results.
                permits = []
                requires = []
                prohibits = []
                identifier = ''
                version = ''

                RDF::Reader.open(rdf_uri) do |reader|
                    reader.each_statement do |s|
                        object = s.object.to_s.gsub(cc, '').gsub(dc, '')
                        predicate = s.predicate.to_s

                        # CC's licenses use DC, FSF's use dcQ. We test both.
                        identifier = object if predicate == dc + 'identifier'
                        identifier = object if predicate == dcq + 'identifier'

                        version = object    if predicate == dcq + 'hasVersion'
                        permits << object   if predicate == cc_permits
                        requires << object  if predicate == cc_requires
                        prohibits << object if predicate == cc_prohibits
                    end
                end

                new(identifier, version, permits, requires, prohibits)
            end

            def initialize(identifier, version, permits, requires, prohibits)
                @identifier, @version = identifier.upcase, version

                @permits = permits.sort
                @requires = requires.sort
                @prohibits = prohibits.sort
            end

            def copyleft?
                @requires.include? 'Copyleft'
            end

            def lesser_copyleft?
                @requires.include? 'LesserCopyleft'
            end

            def sharealike?
                @requires.include? 'ShareAlike'
            end

            def permissive?
                not (copyleft? or lesser_copyleft? or sharealike?) and
                (@permits <=> ['DerivativeWorks', 'Distribution', 'Reproduction']) >= 0
            end

            def to_s
                permits = @permits.join(', ') if not @permits.empty?
                requires = @requires.join(', ') if not @requires.empty?
                prohibits = @prohibits.join(', ') if not @prohibits.empty?

                """
                #{@identifier} #{@version}
                Permits: #{permits || '---'}
                Requires: #{requires || '---'}
                Prohibits: #{prohibits || '---'}
                """.strip.gsub(/  +/, '')
            end

            private
            def combinable_with_ccrel?(other)
                # You can't combine with something that you can't make
                # derivative works of.
                if not (permits.include? 'DerivativeWorks' and other.permits.include? 'DerivativeWorks')
                    return false
                end

                # If any of the licenses is Copyleft or ShareAlike, being
                # combinable is the same as being relicensable. We just check if
                # any of the licenses is relicensable into the other.
                if (copyleft? or sharealike?) or
                    (other.copyleft? or other.sharealike?)
                    return (relicensable_to?(other) or other.relicensable_to?(self))
                end

                true
            end

            def relicensable_to_ccrel?(other)
                # You can't change the license of something that you can't make
                # derivative works of.
                return false if not permits.include? 'DerivativeWorks'

                # If I am Copyleft or Lesser Copyleft, I can only relicense to the
                # same license (version matters).
                return self == other if copyleft? or lesser_copyleft?

                # If I am ShareAlike, I can only relicense to the same license,
                # independent of which version.
                return identifier == other.identifier if sharealike?

                # The target license can remove permissions, but not add.
                return false if permits | other.permits != permits

                # The target license can add requirements, but not remove.
                return false if requires & other.requires != requires

                # The target license can add prohibitions, but not remove.
                return false if prohibits & other.prohibits != prohibits

                true
            end
        end
    end
end
