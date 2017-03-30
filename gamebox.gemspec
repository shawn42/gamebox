# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gamebox/version"

Gem::Specification.new do |s|
  s.name        = "gamebox"
  s.version     = Gamebox::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Shawn Anderson", "Jason Roelofs", "Karlin Fox"]
  s.email = %q{shawn42@gmail.com}
  s.homepage = %q{http://shawn42.github.com/gamebox}
  s.description = %q{Framework for building and distributing games using Gosu}
  s.summary = %q{Framework for building and distributing games using Gosu}
  s.rubyforge_project = "gamebox"

  s.files         = `git ls-files`.split("\n").reject{ |f| f[/^examples\//] || f[/^\./] }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "gosu"
  s.add_dependency "rake"
  s.add_dependency "publisher"
  s.add_dependency "conject", ">= 0.0.8"
  s.add_dependency "tween"
  s.add_dependency "i18n"
  s.add_dependency "thor"#, ">= 0.14.6"
  s.add_dependency "require_all"
  s.add_dependency "kvo", ">= 0.1.0"
  s.add_dependency "listen", ">= 2.4.0"

  s.add_development_dependency "pry", '~>0.9.7'
  s.add_development_dependency "pry-remote"
  s.add_development_dependency "rspec-core", '~>2.13.0'
  s.add_development_dependency "rspec-mocks", "~>2.13.0"
  s.add_development_dependency "rspec-expectations", '~>2.13.0'
  s.add_development_dependency "mocha"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "polaris"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "chipmunk"
end

