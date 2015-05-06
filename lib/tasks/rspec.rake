require 'rspec/core/rake_task'

namespace :spec do
  desc "Run all schema specs"
  RSpec::Core::RakeTask.new(:schema => "spec:prepare") do |t|
    t.rspec_opts = '-t schema_test'
  end
end
