require 'rubygems'
require 'rdf/raptor'

class License
    attr_reader :identifier, :version, :permits, :requires, :prohibits

    CC = 'http://creativecommons.org/ns#'
    CC_PERMITS = CC + 'permits'
    CC_REQUIRES = CC + 'requires'
    CC_PROHIBITS = CC + 'prohibits'

    DC = 'http://purl.org/dc/elements/1.1/'
    DCQ = 'http://purl.org/dc/terms/'

    def initialize(rdf_uri)
        @permits = []
        @requires = []
        @prohibits = []
        @identifier = ''

        RDF::Reader.open(rdf_uri) do |reader|
            reader.each_statement do |s|
                object = s.object.to_s.gsub(CC, '').gsub(DC, '')
                predicate = s.predicate.to_s

                # CC's licenses use DC, FSF's use DCQ. We test both.
                @identifier = object if predicate == DC + 'identifier'
                @identifier = object if predicate == DCQ + 'identifier'

                @version = object    if predicate == DCQ + 'hasVersion'
                @permits << object   if predicate == CC_PERMITS
                @requires << object  if predicate == CC_REQUIRES
                @prohibits << object if predicate == CC_PROHIBITS
            end
        end

        @permits.sort!
        @requires.sort!
        @prohibits.sort!
        @identifier.upcase!
    end

    def to_s
        permits = @permits.join(', ') if not @permits.empty?
        requires = @requires.join(', ') if not @requires.empty?
        prohibits = @prohibits.join(', ') if not @prohibits.empty?

        """
        #{@identifier} #{@version}
        Permits: #{permits || '---'}
        Requires: #{requires || '---'}
        Prohibits: #{prohibits || '---'}
        """.strip.gsub(/  +/, '')
    end
end
