# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/rspec/**/*_spec.rb"
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

namespace :spec do
  desc "Run specs with the rspec-loop formatter"
  RSpec::Core::RakeTask.new(:loop) do |t|
    t.pattern = "spec/rspec/**/*_spec.rb"
    t.rspec_opts = "--format RSpec::Loop::Formatter"
  end

  namespace :formatter do
    desc "Run example specs to demonstrate formatter"
    RSpec::Core::RakeTask.new(:example) do |t|
      t.pattern = "spec/example/**/*_spec.rb"
      t.rspec_opts = "--format RSpec::Loop::Formatter"
    end
  end
end
