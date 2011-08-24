# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "valium/version"

Gem::Specification.new do |s|
  s.name        = "valium"
  s.version     = Valium::VERSION
  s.authors     = ["Ernie Miller"]
  s.email       = ["ernie@metautonomo.us"]
  s.homepage    = "http://github.com/ernie/valium"
  s.summary     = %q{
    Access attribute values directly, without instantiating ActiveRecord objects.
  }
  s.description = %q{
    Suffering from ActiveRecord instantiation anxiety? Try Valium. It
    saves your CPU and memory for more important things, retrieving
    just the values you're interested in seeing.
  }

  s.rubyforge_project = "valium"

  s.add_dependency 'activerecord', '>= 3.0'
  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
