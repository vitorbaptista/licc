require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/licc'

Hoe.plugin :newgem
Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'licc' do
  self.developer 'Vitor Baptista', 'vitor@vitorbaptista.com'
  self.rubyforge_name       = self.name # TODO this is default value
  self.extra_deps           = [['rdf-raptor','>= 0.4.0'],
                               ['trollop', '>= 1.16']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
