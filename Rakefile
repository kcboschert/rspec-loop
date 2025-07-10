# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

namespace :spec do
  desc "Run specs in a loop"
  RSpec::Core::RakeTask.new(:loop) do |t|
    t.rspec_opts = "--format RSpec::Loop::Formatter"
  end
end
