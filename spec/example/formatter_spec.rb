# frozen_string_literal: true

RSpec.describe "rspec-loop formatter examples", loop: 3, type: :example do
  it "formats successes" do
    expect(true).to eq(true)
  end

  it "formats some failures" do
    expect([1, 2].sample).to be_even
  end

  it "formats failures" do
    expect(true).to be_false
  end

  it "formats tests that are pending" do
    pending
    expect(true).to be_false
  end

  xit "formats tests skipped with xit" do
    raise "BOOM!"
  end
end
