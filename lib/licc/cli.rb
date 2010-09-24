require 'licc/license'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            arguments.each { |license|
                license_path = license
                if not File.exists? license_path
                    license_path = LICENSES_FOLDER + license.downcase + '.rdf'
                end
                if File.exists? license_path
                    puts License.parse(license_path)
                else
                    puts "Unknown license \"#{license}\""
                end
            }
        end
    end
end
