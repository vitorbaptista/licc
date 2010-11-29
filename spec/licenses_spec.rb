require File.dirname(__FILE__) + '/spec_helper.rb'
require 'licc/license'
require 'licc/licenses'
require 'licc/license_compatibility_exception'

describe Licc::Licenses do
    before(:all) do
        initialize_licenses
    end

    it "should accept an array of licenses" do
        licenses = [@gpl, @bsd]
        l = Licc::Licenses.new(licenses)
        l.licenses.should == licenses
    end

    it "should ignore repeated licenses in the array it was initialized with" do
        licenses = [@gpl, @bsd]
        l = Licc::Licenses.new(licenses + licenses)
        l.licenses.should == licenses
    end

    it "should accept Licenses + License" do
        licenses = [@by, @by_nc]
        l = Licc::Licenses.new(licenses)
        l += @by_nc_sa
        l.licenses.should == licenses + [@by_nc_sa]
    end

    it "should accept Licenses + Licenses" do
        licenses = [@by, @by_nc]
        l = Licc::Licenses.new(licenses)
        l2 = Licc::Licenses.new([@by_nc_sa])

        l += l2
        l.licenses.should == licenses + [@by_nc_sa]
    end

    it "should ignore repeated licenses when adding with another Licenses object" do
        licenses = [@by, @by_nc]
        l = Licc::Licenses.new(licenses)
        l2 = Licc::Licenses.new(licenses + [@by])

        l += l2
        l.licenses.should == licenses
    end

    it "should ignore repeated licenses when adding with another License object" do
        licenses = [@by, @by_nc]
        l = Licc::Licenses.new(licenses)

        l += @by
        l += @by_nc_sa
        l.licenses.should == licenses + [@by_nc_sa]
    end

    it "should detect known combinable license as such" do
        licenses = [@gpl, @bsd]
        lambda{Licc::Licenses.new(licenses)}.should_not raise_error(Licc::LicenseCompatibilityException)
    end

    it "should detect known non-combinable license as such" do
        licenses = [@gpl, @bsd, @by_sa]
        lambda{Licc::Licenses.new(licenses)}.should raise_error(Licc::LicenseCompatibilityException)
    end
end
