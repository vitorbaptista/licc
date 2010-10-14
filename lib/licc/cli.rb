require 'rubygems'
require 'trollop'
require 'licc/license'
require 'licc/licenses'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            @stdout, @stdin = stdout, stdin

            @known_licenses = Hash.new
            Dir.glob(LICENSES_FOLDER + '*.rdf').each { |path|
                license = File.basename(path, '.rdf')
                @known_licenses[license] = path
            }

            opts = parse!(arguments)
            licenses = Licenses.new(parse_licenses(opts[:licenses]))
            if opts[:to]
                to = parse_licenses(opts[:to]).first
                exit -1 if not licenses.relicensable_to? to
            else
                @stdout.puts licenses
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

        def self.parse_licenses(licenses, known_licenses=@known_licenses)
            result = Array.new
            licenses.each { |license|
                license_path = license
                if known_licenses.has_key? license.downcase
                    license_path = known_licenses[license.downcase]
                end
                if File.exists? license_path
                    result << License.parse(license_path)
                else
                    @stdout.puts "Unknown license \"#{license}\""
                    exit -1
                end
            }

            result
        end
    end
end
