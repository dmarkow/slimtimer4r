# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "slimtimer4r/version"

Gem::Specification.new do |s|
  s.name        = "slimtimer4r"
  s.version     = SlimTimer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "slimtimer4r"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "faraday", "~> 0.5.4"
  s.add_runtime_dependency "faraday_middleware"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "multi_xml"
  s.add_runtime_dependency "hashie"
  s.add_development_dependency "rspec", "~> 2.4.0"
  # s.add_development_dependency "fakeweb"
  s.add_development_dependency "webmock"
end
