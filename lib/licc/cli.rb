require 'licc/license'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            arguments.each { |license|
                if not File.exists? license
                    license = LICENSES_FOLDER + license.downcase + '.rdf'
                end
                puts License.parse(license) if File.exists? license
            }
        end
    end
end
