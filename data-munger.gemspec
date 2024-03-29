# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "data_munger/version"

Gem::Specification.new do |s|
  s.name        = "data_munger"
  s.version     = DataMunger::VERSION
  s.authors     = ["Adam Davies"]
  s.email       = ["adam@36zeroes.com.au"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "data-munger"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'hashie'

  s.add_development_dependency 'rake', '~> 0.9'
  s.add_development_dependency 'rspec', '~> 2.6'
  #s.add_development_dependency 'ruby-debug'  # for nice rspec output
  s.add_development_dependency 'awesome_print'  # for nice rspec output
  s.add_development_dependency 'fuubar'  # for nice rspec output
end
