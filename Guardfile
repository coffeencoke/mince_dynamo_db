# A sample Guardfile
# More info at https://github.com/guard/guard#readme
#

guard 'rspec', :version => 2 do
  watch(%r{^spec/lib/.+_spec\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch(%r{^lib/mince_dynamo_db/.+\.rb$})
  watch(%r{^lib/(.+)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch(%r{^spec/support/shared_examples/(.+)\.rb$})  { "spec" }
end

