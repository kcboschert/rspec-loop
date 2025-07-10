# frozen_string_literal: true

require "rspec/core"
require_relative "loop/version"
require_relative "loop/formatter"
require_relative "core/example"

module RSpec
  class Loop
    DEFAULT_LOOP_COUNT = 3
    class << self
      def setup
        RSpec.configure do |config|
          config.add_setting :default_loop_count, default: DEFAULT_LOOP_COUNT

          config.around(:example) do |example|
            RSpec::Loop.new(example).run
          end
        end

        RSpec::Core::Example::Procsy.include(RSpecExampleProcsyLoop)
        RSpec::Core::Example.include(RSpecExampleLoop)
      end
    end

    attr_reader :procsy

    def initialize(procsy)
      @procsy = procsy
    end

    def run(...)
      loop_results = []
      @procsy.metadata[:loop_results] = loop_results

      @procsy.loop_count.times do
        @procsy.exception = nil
        @procsy.reporter.notify(:example_iteration_started, RSpec::Core::Notifications::ExampleNotification.for(@procsy))
        result = Core::Example::ExecutionResult.new
        result.started_at = Time.now

        @procsy.run(...)

        result.finished_at = Time.now
        result.run_time = result.finished_at - result.started_at
        result.exception = @procsy.exception.dup
        result.pending_message = @procsy.execution_result.pending_message.dup
        result.status = (result.pending_message && :pending) ||
                        (result.exception && :failed) ||
                        :passed
        loop_results << result
        @procsy.metadata[:loop_last_result] = result

        @procsy.reporter.notify(:example_iteration_finished, RSpec::Core::Notifications::ExampleNotification.for(@procsy))
      end

      @procsy.exception = loop_results.map(&:exception).compact.first
      pending_message = loop_results.map(&:pending_message).compact.first

      @procsy.execution_result.status = (@procsy.exception && :failed) || (pending_message && :pending) || :passed
      @procsy.execution_result.pending_message = pending_message
      @procsy.execution_result.exception = @procsy.exception
      @procsy.execution_result.started_at = loop_results.first.started_at
      @procsy.execution_result.finished_at = loop_results.last.finished_at
      @procsy.execution_result.run_time = @procsy.execution_result.finished_at - @procsy.execution_result.started_at
    end
  end
end

RSpec::Loop.setup
