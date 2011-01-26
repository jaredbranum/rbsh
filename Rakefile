require 'rspec/core/rake_task'

desc "Run RSpec tests"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb"
end

desc 'Default: run test suite'
task :default => :spec