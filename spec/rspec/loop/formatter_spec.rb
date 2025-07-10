# frozen_string_literal: true

RSpec.describe RSpec::Loop::Formatter do
  subject!(:formatter) { described_class.new(out) }
  let!(:out) { StringIO.new }
  let!(:reporter) do
    RSpec::Core::Reporter.new(RSpec::Core::Configuration.new)
  end
  let(:default_loop_count) { RSpec::Loop::DEFAULT_LOOP_COUNT }
  let(:success_char) { RSpec::Core::Formatters::ConsoleCodes.wrap(".", :success) }
  let(:failure_char) { RSpec::Core::Formatters::ConsoleCodes.wrap("F", :failure) }
  let(:pending_char) { RSpec::Core::Formatters::ConsoleCodes.wrap("*", :pending) }

  before(:each) do
    reporter.register_listener(formatter, *RSpec::Loop::Formatter::NOTIFICATIONS)
  end

  context "all passed" do
    it "outputs success characters for each run that passes" do
      RSpec.describe("group") do
        example("example") { expect(true).to eq(true) }
      end.run(reporter)

      expect(out.string).to eq(<<~RESULT)

        group
          [#{success_char * default_loop_count}] #{RSpec::Core::Formatters::ConsoleCodes.wrap("example", :success)}
      RESULT
    end
  end

  (1..3).each do |num_failures|
    context "#{num_failures}/3 failures" do
      it "outputs failure characters for each run that fails" do
        expected_success = default_loop_count - num_failures
        count = 0
        success = 0
        RSpec.describe("group") do
          example("example") do
            count += 1
            raise "BOOM!" if count <= num_failures

            success += 1
          end
        end.run(reporter)

        expect(success).to eq(expected_success)
        expect(out.string).to eq(<<~RESULT)

          group
            [#{failure_char * num_failures}#{success_char * expected_success}] #{RSpec::Core::Formatters::ConsoleCodes.wrap("example", :failure)}
        RESULT
      end
    end
  end

  context "pending" do
    it "outputs pending characters for each run that's pending" do
      count = 0
      RSpec.describe("group") do
        example("example") do
          count += 1
          pending "reason"
          raise "BOOM!"
        end
      end.run(reporter)

      expect(count).to eq(default_loop_count)
      expect(out.string).to eq(<<~RESULT)

        group
          [#{pending_char * default_loop_count}] #{RSpec::Core::Formatters::ConsoleCodes.wrap("example", :pending)}
      RESULT
    end
  end

  context "skipped via skip" do
    it "outputs pending characters for each skipped run" do
      count = 0

      RSpec.describe("group") do
        it("example") do
          count += 1
          skip "reason"
        end
      end.run(reporter)

      expect(count).to eq(default_loop_count)
      expect(out.string).to eq(<<~RESULT)

        group
          [#{pending_char * default_loop_count}] #{RSpec::Core::Formatters::ConsoleCodes.wrap("example", :pending)}
      RESULT
    end
  end

  context "skipped via xit" do
    it "outputs pending characters for each skipped run" do
      count = 0

      RSpec.describe("group") do
        xit("example") do
          count += 1
        end
      end.run(reporter)

      expect(count).to eq(0)
      expect(out.string).to eq(<<~RESULT)

        group
          [#{pending_char * default_loop_count}] #{RSpec::Core::Formatters::ConsoleCodes.wrap("example", :pending)}
      RESULT
    end
  end
end
