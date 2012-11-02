# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mince_dynamo_db/version"

Gem::Specification.new do |s|
  s.name        = "mince_dynamo_db"
  s.version     = MinceDynamoDb.version
  s.authors     = ["Matt Simpson"]
  s.email       = ["matt@railsgrammer.com"]
  s.homepage    = "https://github.com/coffeencoke/mince_dynamo_db"
  s.summary     = %q{Lightweight ORM for Amazon's DynamoDB with Ruby Apps}
  s.description = %q{Lightweight ORM for Amazon's DynamoDB with Ruby Apps}

  s.rubyforge_project = "mince_dynamo_db"

  s.files = %w(
    lib/mince_dynamo_db.rb
    lib/mince_dynamo_db/config.rb
    lib/mince_dynamo_db/connection.rb
    lib/mince_dynamo_db/data_sanitizer.rb
    lib/mince_dynamo_db/data_store.rb
    lib/mince_dynamo_db/interface.rb
    lib/mince_dynamo_db/version.rb
  )
  s.test_files = %w(
    spec/integration/mince_interface_spec.rb
    spec/units/config_spec.rb
    spec/units/connection_spec.rb
    spec/units/data_sanitizer_spec.rb
    spec/units/data_store_spec.rb
    spec/units/interface_spec.rb
  )
  s.require_paths = ["lib"]

  s.add_dependency 'aws-sdk', "~> 1.3.7"
  s.add_dependency 'activesupport', "~> 3.0"

  s.add_development_dependency('rake', '~> 0.9')
  s.add_development_dependency "rspec", "~> 2.8.0"
  s.add_development_dependency "guard-rspec", "~> 0.6.0"
  s.add_development_dependency "yard", "~> 0.7.5"
  s.add_development_dependency "redcarpet", "~> 2.1.1"
  s.add_development_dependency "mince", "~> 2.0.0.pre.2"
end
