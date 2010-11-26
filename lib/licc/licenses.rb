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
            # Tests if each license is relicensable to our target license.
            @licenses.each { |lic|
                return false if not lic.relicensable_to? other
            }

            true
        end

        def +(other)
            if other.respond_to? "licenses"
                @licenses |= other.licenses
            else
                @licenses |= [other]
            end

            @licenses.uniq!

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
