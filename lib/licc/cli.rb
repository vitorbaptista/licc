require 'rubygems'
require 'trollop'
require 'licc/license'
require 'licc/licenses'
require 'licc/license_compatibility_exception'

module Licc
    class CLI
        LICENSES_FOLDER = File.dirname(__FILE__) + '/licenses/'

        def self.execute(stdout=STDOUT, stdin=STDIN, arguments=[])
            @stdout, @stdin = stdout, stdin

            @known_licenses = Hash.new
            Dir.glob(LICENSES_FOLDER + '*.rdf').each { |path|
                license = File.basename(path, '.rdf').upcase
                @known_licenses[license] = path
            }

            opts = parse!(arguments)

            begin
                licenses = Licenses.new(parse_licenses(opts[:licenses]))
            rescue LicenseCompatibilityException
                exit -1
            end

            if opts[:to]
                if opts[:to].upcase == 'ANY'
                    relicensable_to = []
                    @known_licenses.each_key { |license|
                        license = parse_licenses(license).first
                        relicensable_to << "#{license.identifier} #{license.version}" if licenses.relicensable_to? license
                    }
                    exit -1 if relicensable_to.empty?
                    puts relicensable_to.join(', ')
                else
                    to = parse_licenses(opts[:to]).first
                    exit -1 if not licenses.relicensable_to? to
                end
            elsif opts[:list_licenses]
                @stdout.puts @known_licenses.keys.sort.join(', ')
            elsif not opts[:licenses].empty?
                @stdout.puts licenses
            end
        end

        def self.parse!(arguments)
            opts = Trollop::options(arguments) do
                opt :to, "Relicense to (use ANY to see all possibilities)", :type => :string
                opt :list_licenses, "List all known licenses"
            end

            # We consider the remaining arguments as licenses
            opts[:licenses] = arguments

            opts
        end

        def self.parse_licenses(licenses, known_licenses=@known_licenses)
            result = Array.new
            licenses.each { |license|
                license_path = license
                if known_licenses.has_key? license.upcase
                    license_path = known_licenses[license.upcase]
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
