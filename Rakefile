# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

require_relative "config/application"
require "standard/rake"

Rails.application.load_tasks
# Rails already defines a :default task. We need to clear it first,
# otherwise Rake will append it to the original task execution.
# Both tasks will be executed.
Rake::Task["default"].clear

RSpec::Core::RakeTask.new(:rspec)

desc "Run the test suite"
task default: [:rspec, :standard]
