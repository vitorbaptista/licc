# Load every *.rb file that's under ./rels
FOLDER = File.dirname(__FILE__) + '/rels'
$LOAD_PATH.unshift(FOLDER)
Dir[File.join(FOLDER, "*.rb")].each {|file| require File.basename(file) }

require 'licc/unknown_license_format_error'

module Licc
    module License
        attr_reader :identifier, :version

        def self.parse(license)
            # Try to parse the license with every class into the Licc::License
            # module. Returns the first that parsed without throwing any exception.
            # Or, if no parser could parse, throw UnknownLicenseFormatError.
            self.constants.each { |type|
                begin
                    return eval(type).parse(license)
                rescue Errno::ENOENT
                    raise
                rescue
                    next
                end
            }

            raise Licc::UnknownLicenseFormatError, license
        end

        def combinable_with?(other)
            klass = other.class.to_s.split('::').last.downcase
            method = "combinable_with_#{klass}?"

            begin
                return send(method,other)
            rescue NoMethodError
                puts "No method found!"
            end
        end

        def relicensable_to?(other)
            klass = other.class.to_s.split('::').last.downcase
            method = "relicensable_to_#{klass}?"

            begin
                return send(method,other)
            rescue NoMethodError
                puts "No method found!"
            end
        end

        def +(other)
            Licenses.new([self, other])
        end

        def ==(other)
            self.to_s == other.to_s
        end

    end
end
