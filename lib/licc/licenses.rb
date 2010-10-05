require 'rubygems'
require 'licc/license'

module Licc
    class Licenses
        attr_accessor :licenses

        def initialize(licenses)
            @licenses = licenses.uniq
        end

        def combinable?
            # Copyleft licenses are compatible if they're the same or if they're
            # explicitly compatible. We don't need to test if they're the same,
            # because we only have unique licenses. So we only test the latter.

            # Lesser Copyleft licenses are compatible for combination depending on
            # the specific license. LGPL, for example, permits dynamic linking.
            # Should we create new attributes for this information?

            # ShareAlike licenses are compatible with itselves, newer versions of
            # itselves or versions from other juridisctions. We don't parse the
            # jurisdiction and, as in Copyleft, we already know that we have unique
            # versions. So, we only need to check if it's a new version of itself.

            # Tests if each license is combinable with every other.
            @licenses.each { |license|
                (@licenses - [license]).each { |other|
                    return false if not license.combinable_with? other
                }
            }

            true
        end

        def relicensable_to?(other)
            combinable = Licenses.new(@licenses + [other]).combinable?
            return false if not combinable

            # Look for the non-permissive license. There'll be only one,
            # because if there were more, they wouldn't be combinable, and the
            # program wouldn't reach this point (This will change when we
            # correct the combination for Lesser Copyleft licenses)
            non_permissive = @licenses.select { |lic|
                lic.copyleft? or lic.lesser_copyleft? or lic.sharealike?
            }.first

            # OK if there are no non-permissive licenses
            return true if non_permissive.nil?

            # OK if the non-permissive license is ShareAlike and is the same as
            # we're trying to license into (version don't matters).
            return true if non_permissive.sharealike? and
                           non_permissive.identifier == other.identifier

            # OK if we're trying to relicense in the same license (version
            # matters).
            return true if non_permissive == other

            # FALSE otherwise.
            return false if not non_permissive.include? other
        end

        def +(other)
            if other.respond_to? "licenses"
                @licenses |= other.licenses
            else
                @licenses |= [other]
            end

            self
        end

        def to_s
            exit -1 if not combinable?
            
            combination = licenses.first
            names = []
            licenses.each { |license|
                names << "#{license.identifier} #{license.version}".strip
                combination += license
            }

            result = combination.to_s.split("\n")
            result.shift

            """
            #{names.join(', ')}
            #{result.join("\n")}
            """.strip.gsub(/  +/, '')
        end
    end
end
