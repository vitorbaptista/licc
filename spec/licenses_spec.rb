require File.dirname(__FILE__) + '/spec_helper.rb'
require 'licc/license'
require 'licc/licenses'

describe Licc::Licenses do
  before(:all) do
    permissions = ['DerivativeWorks', 'Distribution', 'Reproduction']
    gpl_requirements = ['Copyleft', 'Notice', 'SourceCode']
    by_sa_requirements = ['Attribution', 'Notice', 'ShareAlike']
    @gpl = Licc::License.new('GPL', '3.0', permissions, gpl_requirements, [])
    @bsd = Licc::License.new('BSD', '', permissions, ['Notice'], [])
    @by  = Licc::License.new('BY', '3.0', permissions, ['Attribution', 'Notice'], [])
    @by_sa  = Licc::License.new('BY-SA', '3.0', permissions, by_sa_requirements, [])
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
    licenses = [@gpl, @bsd]
    l = Licc::Licenses.new(licenses)
    l += @by
    l.licenses.should == licenses + [@by]
  end

  it "should accept Licenses + Licenses" do
    licenses = [@gpl, @bsd]
    l = Licc::Licenses.new(licenses)
    l2 = Licc::Licenses.new([@by])

    l += l2
    l.licenses.should == licenses + [@by]
  end

  it "should ignore repeated licenses when adding with another Licenses object" do
    licenses = [@gpl, @bsd]
    l = Licc::Licenses.new(licenses)
    l2 = Licc::Licenses.new(licenses + [@by])

    l += l2
    l.licenses.should == licenses + [@by]
  end

  it "should ignore repeated licenses when adding with another License object" do
    licenses = [@gpl, @bsd]
    l = Licc::Licenses.new(licenses)

    l += @gpl
    l += @by
    l.licenses.should == licenses + [@by]
  end

  it "should detect known combinable license as such" do
    licenses = [@gpl, @bsd, @by]
    l = Licc::Licenses.new(licenses)
    l.combinable?.should == true
  end

  it "should detect known non-combinable license as such" do
    licenses = [@gpl, @bsd, @by_sa]
    l = Licc::Licenses.new(licenses)
    l.combinable?.should == false
  end
end
