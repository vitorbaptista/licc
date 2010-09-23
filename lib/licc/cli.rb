require 'licc/license'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            arguments.each { |license|
                license_path = LICENSES_FOLDER + license.downcase + '.rdf'
                puts License.parse(license_path) if File.exists? license_path
            }
        end
    end
end
