# frozen_string_literal: true

RSpec.describe RSpec::Loop do
  let(:default_loop_count) { RSpec::Loop::DEFAULT_LOOP_COUNT }

  it "has a version number" do
    expect(RSpec::Loop::VERSION).not_to be nil
  end

  context "example iterations" do
    context "default loop" do
      it "runs three times" do
        count = 0

        RSpec.describe do
          example { count += 1 }
        end.run

        expect(count).to eq(default_loop_count)
      end
    end

    context "configured loop" do
      it "runs the configured number of times" do
        count = 0

        RSpec.configuration.default_loop_count = 5

        RSpec.describe do
          example { count += 1 }
        end.run

        expect(count).to eq(5)
      end
    end

    context "metadata loop" do
      it "runs the specified number of times" do
        count = 0

        RSpec.describe do
          example("ex", loop: 5) { count += 1 }
        end.run

        expect(count).to eq(5)
      end
    end
  end

  context "group iterations" do
    context "default loop" do
      it "runs three times" do
        count1 = 0
        count2 = 0

        RSpec.describe do
          example { count1 += 1 }
          example { count2 += 1 }
        end.run

        expect(count1).to eq(default_loop_count)
        expect(count2).to eq(default_loop_count)
      end
    end

    context "configured loop" do
      it "runs the configured number of times" do
        RSpec.configuration.default_loop_count = 5

        count1 = 0
        count2 = 0

        RSpec.describe do
          example { count1 += 1 }
          example { count2 += 1 }
        end.run

        expect(count1).to eq(5)
        expect(count2).to eq(5)
      end
    end

    context "metadata loop" do
      it "runs the specified number of times" do
        count1 = 0
        count2 = 0

        RSpec.describe("group", loop: 5) do
          example { count1 += 1 }
          example { count2 += 1 }
        end.run

        expect(count1).to eq(5)
        expect(count2).to eq(5)
      end
    end
  end

  context "execution result" do
    context "all passed" do
      it "sets the result to passed" do
        count = 0
        ex = nil

        RSpec.describe do
          ex = example do
            count += 1
          end
        end.run

        expect(count).to eq(default_loop_count)
        expect(ex.execution_result.status).to eq(:passed)
        expect(ex.execution_result.pending_message).to eq(nil)
        expect(ex.execution_result.started_at).to be_a(Time)
        expect(ex.execution_result.finished_at).to be_a(Time)
        delta_time = ex.execution_result.finished_at - ex.execution_result.started_at
        expect(ex.execution_result.run_time).to eq(delta_time)
        expect(ex.execution_result.exception).to eq(nil)
      end
    end

    (1..3).each do |num_failures|
      context "#{num_failures}/3 failures" do
        it "sets the result to failed" do
          count = 0
          ex = nil

          RSpec.describe do
            ex = example do
              count += 1
              raise "BOOM #{count}!" if count <= num_failures
            end
          end.run

          expect(count).to eq(default_loop_count)
          expect(ex.execution_result.status).to eq(:failed)
          expect(ex.execution_result.pending_message).to eq(nil)
          expect(ex.execution_result.started_at).to be_a(Time)
          expect(ex.execution_result.finished_at).to be_a(Time)
          delta_time = ex.execution_result.finished_at - ex.execution_result.started_at
          expect(ex.execution_result.run_time).to eq(delta_time)
          expect(ex.execution_result.exception).not_to be_nil

          # always the first exception
          expect(ex.execution_result.exception.message).to eq("BOOM 1!")
        end
      end
    end

    context "pending" do
      it "sets the result to pending" do
        count = 0
        ex = nil

        RSpec.describe do
          ex = example do
            count += 1
            pending "reason"
            raise "BOOM!"
          end
        end.run

        expect(count).to eq(default_loop_count)
        expect(ex.execution_result.status).to eq(:pending)
        expect(ex.execution_result.pending_message).to eq("reason")
        expect(ex.execution_result.started_at).to be_a(Time)
        expect(ex.execution_result.finished_at).to be_a(Time)
        delta_time = ex.execution_result.finished_at - ex.execution_result.started_at
        expect(ex.execution_result.run_time).to eq(delta_time)
        expect(ex.execution_result.exception).to eq(nil)
      end
    end

    context "skipped" do
      it "sets the result to pending" do
        count = 0
        ex = nil

        RSpec.describe do
          ex = example do
            count += 1
            skip "reason"
            raise "BOOM!"
          end
        end.run

        expect(count).to eq(default_loop_count)
        expect(ex.execution_result.status).to eq(:pending)
        expect(ex.execution_result.pending_message).to eq("reason")
        expect(ex.execution_result.started_at).to be_a(Time)
        expect(ex.execution_result.finished_at).to be_a(Time)
        delta_time = ex.execution_result.finished_at - ex.execution_result.started_at
        expect(ex.execution_result.run_time).to eq(delta_time)
        expect(ex.execution_result.exception).to eq(nil)
      end
    end
  end

  context "notifications" do
    it "emits an example_iteration_started and example_iteration_finished notification" do
      started = 0
      finished = 0

      reporter = RSpec::Core::Reporter.new(RSpec::Core::Configuration.new)
      listener = double("Listener")
      default_loop_count.times do
        expect(listener).to(receive(:example_iteration_started).ordered { |_| started += 1 })
        expect(listener).to(receive(:example_iteration_finished).ordered { |_| finished += 1 })
      end

      reporter.register_listener(listener, :example_iteration_started, :example_iteration_finished)

      RSpec.describe do
        example do
          count += 1
          raise "BOOM #{count}!" if count <= 1
        end
      end.run(reporter)

      expect(started).to eq(default_loop_count)
      expect(finished).to eq(default_loop_count)
    end
  end
end
