require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'

  desc 'Default: run specs.'
  task :default => :spec

  desc "Run specs"
  RSpec::Core::RakeTask.new 
rescue LoadError
end
