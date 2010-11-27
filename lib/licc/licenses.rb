require 'rubygems'
require 'licc/license'

module Licc
    class Licenses
        attr_reader :licenses

        def initialize(licenses)
            @licenses = licenses.uniq

            combinable?
        end

        def combinable?
            combinable_with? self
        end

        def combinable_with?(other)
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

            # If 'other' is also a Licenses, we test against each license it
            # contains.
            if other.respond_to? "licenses"
                other.licenses.each { |license|
                    @licenses |= [license] if combinable_with? license
                }
            end

            # Tests if each license is combinable with every other.
            (@licenses + [other]).each { |license|
                (@licenses - [license]).each { |other|
                    raise LicenseCompatibilityException if not license.combinable_with? other
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
            other = Licenses.new([other]) if not other.respond_to? "licenses"

            combinable_with? other

            self
        end

        def to_s
            # If we have a Copyleft or a ShareAlike license, only print it.
            copyleft_or_sa = @licenses.find_all { |license|
                license.copyleft? or license.sharealike?
            }

            # But if there're more than one Copyleft or ShareAlike (most
            # probably, if this is the case it's a ShareAlike license), we
            # print the one with the newer version.
            if newer_version = copyleft_or_sa.shift
                copyleft_or_sa.each { |license|
                    newer_version = license if license.version > newer_version.version
                }

                return newer_version.to_s
            end

            permits = []
            requires = []
            prohibits = []
            names = []

            licenses.each { |license|
                names << "#{license.identifier} #{license.version}".strip
                permits = license.permits if permits.empty?
                permits &= license.permits
                requires |= license.requires
                prohibits |= license.prohibits
            }

            permits = permits.join(', ') if not permits.empty?
            requires = requires.join(', ') if not requires.empty?
            prohibits = prohibits.join(', ') if not prohibits.empty?

            """
            #{names.join(', ')}
            Permits: #{permits || '---'}
            Requires: #{requires || '---'}
            Prohibits: #{prohibits || '---'}
            """.strip.gsub(/  +/, '')
        end
    end
end
