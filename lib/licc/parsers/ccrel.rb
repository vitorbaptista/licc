require 'rubygems'
require 'rdf/raptor'
require 'licc/licenses/ccrel'

module Licc
    module Parser
        module CCREL
            # RDF predicates used by CCREL.
            CC = 'http://creativecommons.org/ns#'
            CC_PERMITS = CC + 'permits'
            CC_REQUIRES = CC + 'requires'
            CC_PROHIBITS = CC + 'prohibits'

            DC = 'http://purl.org/dc/elements/1.1/'
            DCQ = 'http://purl.org/dc/terms/'

            def self.parse(rdf_uri)
                # Initializing variables that will hold the results.
                permits = []
                requires = []
                prohibits = []
                identifier = ''
                version = ''

                RDF::Reader.open(rdf_uri) do |reader|
                    reader.each_statement do |s|
                        object = s.object.to_s.gsub(CC, '').gsub(DC, '')
                        predicate = s.predicate.to_s

                        # CC's licenses use DC, FSF's use DCQ. We test both.
                        identifier = object if predicate == DC + 'identifier'
                        identifier = object if predicate == DCQ + 'identifier'

                        version = object    if predicate == DCQ + 'hasVersion'
                        permits << object   if predicate == CC_PERMITS
                        requires << object  if predicate == CC_REQUIRES
                        prohibits << object if predicate == CC_PROHIBITS
                    end
                end

                Licc::License::CCREL.new(identifier, version, permits, requires, prohibits)
            end
        end
    end
end
