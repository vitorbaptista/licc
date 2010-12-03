begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'licc'
require 'licc/license'

def initialize_licenses
    permissions = ['DerivativeWorks', 'Distribution', 'Reproduction']
    gpl_requirements = ['Copyleft', 'Notice', 'SourceCode']
    lgpl_requirements = ['LesserCopyleft', 'Notice', 'SourceCode']
    by_requirements = ['Attribution', 'Notice']
    by_sa_requirements = by_requirements + ['ShareAlike']
    by_nd_permissions = permissions - ['DerivativeWorks']
    non_commercial = ['CommercialUse']

    @gpl = Licc::License::CCREL.new('GPL', '2.0', permissions, gpl_requirements, [])
    @gpl3 = Licc::License::CCREL.new('GPL', '3.0', permissions, gpl_requirements, [])
    @lgpl = Licc::License::CCREL.new('LGPL', '2.1', permissions, lgpl_requirements, [])
    @bsd = Licc::License::CCREL.new('BSD', '', permissions, ['Notice'], [])

    @cc0  = Licc::License::CCREL.new('CC0', '1.0', permissions, [], [])

    @by  = Licc::License::CCREL.new('BY', '3.0', permissions, by_requirements, [])
    @by_sa  = Licc::License::CCREL.new('BY-SA', '3.0', permissions, by_sa_requirements, [])
    @by_nd  = Licc::License::CCREL.new('BY-ND', '3.0', by_nd_permissions, by_requirements, [])
    @by_nc  = Licc::License::CCREL.new('BY-NC', '3.0', permissions, by_requirements, non_commercial)
    @by_nc_nd  = Licc::License::CCREL.new('BY-NC-ND', '3.0', by_nd_permissions, by_requirements, non_commercial)
    @by_nc_sa  = Licc::License::CCREL.new('BY-NC-SA', '3.0', permissions, by_sa_requirements, non_commercial)
end
