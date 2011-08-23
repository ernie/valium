# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "valium/version"

Gem::Specification.new do |s|
  s.name        = "valium"
  s.version     = Valium::VERSION
  s.authors     = ["Ernie Miller"]
  s.email       = ["ernie@metautonomo.us"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "valium"

  s.add_dependency 'activerecord', '>= 3.0'
  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
