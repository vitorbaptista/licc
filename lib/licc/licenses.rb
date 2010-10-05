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

        def +(other)
            if other.respond_to? "licenses"
                @licenses |= other.licenses
            else
                @licenses |= [other]
            end

            self
        end
    end
end
