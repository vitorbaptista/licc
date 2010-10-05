require File.dirname(__FILE__) + '/spec_helper.rb'
require 'licc/license'
require 'licc/licenses'

describe Licc::Licenses do
  before(:all) do
    permissions = ['DerivativeWorks', 'Distribution', 'Reproduction']
    requirements = ['Copyleft', 'Notice', 'SourceCode']
    @gpl = Licc::License.new('GPL', '3.0', permissions, requirements, [])
    @bsd = Licc::License.new('BSD', '', permissions, ['Notice'], [])
    @by  = Licc::License.new('BY', '3.0', permissions, ['Attribution', 'Notice'], [])
  end

  it "should accept an array of licenses" do
    licenses = [@gpl, @bsd]
    l = Licc::Licenses.new(licenses)
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

end
