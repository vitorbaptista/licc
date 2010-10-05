require 'rubygems'
require 'licc/license'

module Licc
  class Licenses
    attr_accessor :licenses

    def initialize(licenses)
      @licenses = licenses.dup
    end

    def +(other)
      if other.respond_to? "licenses"
        @licenses |= other.licenses
      else
        @licenses |= [other]
      end

      self
    end
  end
end
