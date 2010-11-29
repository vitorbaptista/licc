require 'rubygems'
require 'rdf/raptor'

module Licc
    class License
        attr_reader :identifier, :version, :permits, :requires, :prohibits

        CC = 'http://creativecommons.org/ns#'
        CC_PERMITS = CC + 'permits'
        CC_REQUIRES = CC + 'requires'
        CC_PROHIBITS = CC + 'prohibits'

        DC = 'http://purl.org/dc/elements/1.1/'
        DCQ = 'http://purl.org/dc/terms/'

        def self.parse(rdf_uri)
            permits = []
            requires = []
            prohibits = []
            identifier = ''
            version = ''

            RDF::Reader.open(rdf_uri) do |reader|
                reader.each_statement do |s|
                    object = s.object.to_s.gsub(CC, '').gsub(DC, '')
                    predicate = s.predicate.to_s

                    # CC's licenses use DC, FSF's use DCQ. We test both.
                    identifier = object if predicate == DC + 'identifier'
                    identifier = object if predicate == DCQ + 'identifier'

                    version = object    if predicate == DCQ + 'hasVersion'
                    permits << object   if predicate == CC_PERMITS
                    requires << object  if predicate == CC_REQUIRES
                    prohibits << object if predicate == CC_PROHIBITS
                end
            end

            License.new(identifier, version, permits, requires, prohibits)
        end

        def initialize(identifier, version, permits, requires, prohibits)
            @identifier, @version = identifier.upcase, version

            @permits = permits.sort
            @requires = requires.sort
            @prohibits = prohibits.sort
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

        def ==(other)
            self.to_s == other.to_s
        end

        def combinable_with?(other)
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

        def relicensable_to?(other)
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

        def hereditary?
            copyleft? or lesser_copyleft? or sharealike?
        end

        def +(other)
            Licenses.new([self, other])
        end
    end
end
