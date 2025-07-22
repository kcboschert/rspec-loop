# frozen_string_literal: true

RSpec::Support.require_rspec_core "formatters/base_text_formatter"
RSpec::Support.require_rspec_core "formatters/console_codes"

module RSpec
  class Loop
    class Formatter < RSpec::Core::Formatters::BaseTextFormatter
      NOTIFICATIONS = %i[
        example_group_started
        example_started
        example_iteration_finished
        example_finished
        example_group_finished
        dump_pending
        dump_failures
        dump_summary
      ].freeze

      RESULT_CHAR_MAP = {
        passed: ".",
        pending: "*",
        failed: "F",
      }.freeze

      RESULT_COLOR_CODE_MAP = {
        passed: :success,
        pending: :pending,
        failed: :failure,
      }.freeze

      RSpec::Core::Formatters.register self, *NOTIFICATIONS

      def initialize(output)
        super
        @group_level = 0

        @example_running = false
        @messages = []
        @totals = Hash.new do |h, key|
          h[key] = { failed: 0, passed: 0, pending: 0 }
        end
      end

      def example_group_started(notification)
        output.puts if @group_level.zero?
        output.puts "#{current_indentation}#{notification.group.description.strip}"

        @group_level += 1
      end

      def example_group_finished(_notification)
        @group_level -= 1 if @group_level.positive?
      end

      def example_started(_notification)
        @example_running = true
        output.print "#{current_indentation}["
      end

      def example_iteration_finished(notification)
        status = notification.example.metadata[:loop_last_result].status
        return if notification.example.skipped?

        @totals[notification.example.id][status] += 1

        print_char_for_status(status)
      end

      def example_finished(notification)
        @example_running = false

        if notification.example.skipped?
          notification.example.loop_count.times do
            print_char_for_status(:pending)
          end
        end

        code = RESULT_COLOR_CODE_MAP[notification.example.execution_result.status]
        output.puts "] #{RSpec::Core::Formatters::ConsoleCodes.wrap(notification.example.description.strip, code)}"

        flush_messages
      end

      def message(notification)
        if @example_running
          @messages << notification.message
        else
          output.puts "#{current_indentation}#{notification.message}"
        end
      end

      def dump_pending(notification)
        return if RSpec.configuration.respond_to?(:pending_failure_output) &&
                  RSpec.configuration.pending_failure_output == :skip
        return if notification.pending_notifications.empty?

        formatted = "\nPending: (Failures listed here are expected and do not affect your suite's status)\n".dup
        pending_examples = notification.pending_notifications.uniq(&:example)
        pending_examples.each_with_index do |pending, index|
          formatted << pending.fully_formatted(index.next)
        end
        output.puts formatted
      end

      def dump_failures(notification)
        return if notification.failure_notifications.empty?

        output.puts notification.fully_formatted_failed_examples
      end

      def dump_summary(summary)
        output.puts summary.fully_formatted
      end

      private

      def print_char_for_status(status)
        result_char = RESULT_CHAR_MAP[status]
        color_code = RESULT_COLOR_CODE_MAP[status]
        output.print RSpec::Core::Formatters::ConsoleCodes.wrap(result_char, color_code)
      end

      def flush_messages
        @messages.each do |message|
          output.puts "#{current_indentation(1)}#{message}"
        end

        @messages.clear
      end

      def current_indentation(offset = 0)
        "  " * (@group_level + offset)
      end
    end
  end
end
