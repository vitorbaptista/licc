require File.dirname(__FILE__) + '/spec_helper.rb'
require 'licc/license'

describe Licc::License do
    before(:all) do
        initialize_licenses
    end

    it "should be relicensable to other licenses according to CC's Compatibility Chart" do
        origins = [@by, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa]
        targets = [[@by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa],
                   [@by_nc_nd, @by_nc_sa]]

        origins.each_with_index { |origin, index|
           relicensable = targets.fetch(index, []) + [origin]
           unrelicensable = origins - relicensable

           relicensable.each { |license|
               origin.relicensable_to?(license).should == true
           }

           unrelicensable.each { |license|
               origin.relicensable_to?(license).should == false
           }
        }
    end

    it "should be combinable with itself" do
        licenses = [@gpl, @lgpl, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa]

        licenses.each { |license|
            license.combinable_with?(license).should == true
        }
    end

    it "should be relicensable to itself" do
        licenses = [@gpl, @lgpl, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa]

        licenses.each { |license|
            license.relicensable_to?(license).should == true
        }
    end
end
