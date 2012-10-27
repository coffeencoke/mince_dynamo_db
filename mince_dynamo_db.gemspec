# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dynamo_db/version"

Gem::Specification.new do |s|
  s.name        = "mince_dynamo_db"
  s.version     = Mince::DynamoDb.version
  s.authors     = ["Matt Simpson"]
  s.email       = ["matt@railsgrammer.com"]
  s.homepage    = "https://github.com/coffeencoke/mince_dynamo_db"
  s.summary     = %q{Lightweight ORM for Amazon's DynamoDB with Ruby Apps}
  s.description = %q{Lightweight ORM for Amazon's DynamoDB with Ruby Apps}

  s.rubyforge_project = "mince_dynamo_db"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'aws-sdk', "~> 1.3.7"
  s.add_dependency 'activesupport', "~> 3.0"

  s.add_development_dependency('rake', '~> 0.9')
  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "guard-rspec", "~> 0.6.0"
  s.add_development_dependency "yard", "~> 0.7.5"
  s.add_development_dependency "redcarpet", "~> 2.1.1"
  s.add_development_dependency "fake_dynamo"
  s.add_development_dependency "mince", "~> 2.0.0.pre.2"
end
