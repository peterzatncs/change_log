# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "change_log/version"

Gem::Specification.new do |s|
  s.name        = "change_log"
  s.version     = ChangeLog::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Peter Zhang"]
  s.email       = ["peterz@ncs.co.nz"]
  s.homepage    = "http://www.ncs.co.nz"
  s.summary     = %q{Change log gem records every changes for the active record model}
  s.description = %q{A gem for tracking who did what and when it happened -- keeps all the changes done by user into a maintenance log}

  s.rubyforge_project = "change_log"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
