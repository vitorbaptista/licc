# Load every *.rb file that's under ./rels
FOLDER = File.dirname(__FILE__) + '/rels'
$LOAD_PATH.unshift(FOLDER)
Dir[File.join(FOLDER, "*.rb")].each {|file| require File.basename(file) }

require 'licc/unknown_license_format_error'

module Licc
    module License
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
    end
end
