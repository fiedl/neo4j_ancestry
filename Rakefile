begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

load "lib/tasks/db_test_prepare.rake"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec