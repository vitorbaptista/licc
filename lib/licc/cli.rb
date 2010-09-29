require 'rubygems'
require 'trollop'
require 'licc/license'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            opts = parse!(arguments)

            opts[:licenses].each { |license|
                license_path = license
                if not File.exists? license_path
                    license_path = LICENSES_FOLDER + license.downcase + '.rdf'
                end
                if File.exists? license_path
                    puts License.parse(license_path)
                else
                    puts "Unknown license \"#{license}\""
                    exit -1
                end
            }
        end

        def self.parse!(arguments)
            opts = Trollop::options(arguments) do
                opt :to, "Relicense to", :type => :string
            end

            # We consider the remaining arguments as licenses
            opts[:licenses] = arguments

            opts
        end
    end
end
