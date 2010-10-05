require 'rubygems'
require 'trollop'
require 'licc/license'
require 'licc/licenses'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            opts = parse!(arguments)
            licenses = Licenses.new(parse_licenses(opts[:licenses]))
            if opts[:to]
                to = parse_licenses(opts[:to]).first
                result = licenses.relicensable_to? to
                exit -1 if not licenses.relicensable_to? to
            else
                puts licenses if not opts[:to]
            end
        end

        def self.parse!(arguments)
            opts = Trollop::options(arguments) do
                opt :to, "Relicense to", :type => :string
            end

            # We consider the remaining arguments as licenses
            opts[:licenses] = arguments

            opts
        end

        def self.parse_licenses(licenses)
            result = Array.new
            licenses.each { |license|
                license_path = license
                if not File.exists? license_path
                    license_path = LICENSES_FOLDER + license.downcase + '.rdf'
                end
                if File.exists? license_path
                    result << License.parse(license_path)
                else
                    puts "Unknown license \"#{license}\""
                    exit -1
                end
            }

            result
        end
    end
end
