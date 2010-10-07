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
            # OK if they're the same
            return true if self == other

            # OK if any of these is ShareAlike and they have the same
            # identifier (the version doesn't matters)
            return true if (self.sharealike? or other.sharealike?) and
                            other.identifier == self.identifier

            # FAIL if both are Copyleft or ShareAlike
            return false if (self.copyleft? or
                             self.sharealike?) and
                            (other.copyleft? or
                             other.sharealike?)

            # Lesser Copyleft isn't combinable with Copyleft or ShareAlike
            # licenses
            return false if (self.lesser_copyleft? and (other.copyleft? or other.sharealike?)) or
                            (other.lesser_copyleft? and (self.copyleft? or self.sharealike?)) 

            # OK if neither is Copyleft nor ShareAlike. I consider that Lesser
            # Copyleft licenses are combinable, but it depends on how they're
            # combined. We probably should give a warning if this is the case.
            true
        end

        def relicensable_to?(other)
            return false if not combinable_with? other

            # OK if they're the same
            return true if self == other

            # You can't change the license of something that you can't make
            # derivative works of.
            return false if not self.permits.include? 'DerivativeWorks'

            # The target license can remove permissions, but not add.
            other.permits.each { |permission|
                return false if not self.permits.include? permission
            }

            # The target license can add requirements, but not remove.
            self.requires.each { |requirement|
                return false if not other.requires.include? requirement
            }

            # The target license can add prohibitions, but not remove.
            self.prohibits.each { |prohibition|
                return false if not other.prohibits.include? prohibition
            }

            # OK if this is a permissive license
            return true if self.permissive?

            if self.sharealike? and other.sharealike?
                # If both are ShareAlike, they have to have the same identifier
                # (version don't matters).
                return false if self.identifier != other.identifier
            else
                # Otherwise they need to be the same (version matters).
                return false if self != other
            end

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

        def +(other)
            permits = @permits & other.permits
            requires = @requires | other.requires
            prohibits = @prohibits | other.prohibits

            License.new('Combination', '', permits, requires, prohibits)
        end
    end
end
