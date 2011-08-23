require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |rspec|
  rspec.rspec_opts = ['--backtrace']
end

task :default => :spec