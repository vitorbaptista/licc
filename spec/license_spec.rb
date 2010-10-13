require File.dirname(__FILE__) + '/spec_helper.rb'
require 'licc/license'

describe Licc::License do
    before(:all) do
        initialize_licenses
    end

    it "should be relicensable to other licenses according to CC's Compatibility Chart" do
        origins = [@cc0, @by, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa]
        targets = [origins,
                   [@by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa],
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

    it "should be relicensable to other licenses according to GNU Project's Compatibility Matrix" do
        pending("extend ccREL to describe relicensing exceptions")

        origins = [@lgpl, @gpl, @gpl3]
        targets = [[@gpl, @gpl3]]

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

    it "should be relicensable to known compatible licenses" do
        cc = [@cc0, @by, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa]
        gnu = [@gpl, @lgpl, @gpl3]
        targets = [cc + gnu]

        cc.each_with_index { |origin, index|
           relicensable = targets.fetch(index, []) + [origin]
           unrelicensable = gnu - relicensable

           relicensable.each { |license|
               origin.relicensable_to?(license).should == true
           }

           unrelicensable.each { |license|
               origin.relicensable_to?(license).should == false
           }
        }
    end

    it "should be combinable with known compatible licenses" do
        cc = [@cc0, @by, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa]
        gnu = [@gpl, @lgpl, @gpl3]
        all = cc + gnu

        origins = [@cc0, @by, @by_nc, @lgpl]
        targets = [all,
                   all - [@gpl, @gpl3],
                   [@cc0, @by, @by_nc, @by_nc_sa],
                   all - [@by_sa, @by_nc_sa]]

        origins.each_with_index { |origin, index|
           relicensable = targets.fetch(index, []) + [origin]
           unrelicensable = all - relicensable

           relicensable.each { |license|
               origin.combinable_with?(license).should == true
           }

           unrelicensable.each { |license|
               origin.combinable_with?(license).should == false
           }
        }
    end


    it "should give the same result indepent of combination order" do
        licenses = [@gpl, @lgpl, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa, @cc0]

        (licenses.length - 1).times { |i|
            origin = licenses[i]
            target = licenses[i+1]

            origin.combinable_with?(target).should == target.combinable_with?(origin)
        }
    end

    it "should be combinable with itself" do
        licenses = [@gpl, @lgpl, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa, @cc0]

        licenses.each { |license|
            license.combinable_with?(license).should == true
        }
    end

    it "should be relicensable to itself" do
        licenses = [@gpl, @lgpl, @by_nc, @by_nc_nd, @by_nc_sa, @by_nd, @by_sa, @cc0]

        licenses.each { |license|
            license.relicensable_to?(license).should == true
        }
    end
end
