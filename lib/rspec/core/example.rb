# frozen_string_literal: true

module RSpecExampleProcsyLoop
  def loop_count
    example.loop_count
  end

  def exception=(exception)
    example.exception = exception
  end
end

module RSpecExampleLoop
  def exception=(exception)
    @exception = exception
  end

  def loop_count
    metadata[:loop] || RSpec.configuration.default_loop_count
  end
end
