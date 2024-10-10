require "rails_helper"

RSpec.describe Identity do
  let(:identity) { build(:identity) }

  it "is valid" do
    expect(identity).to be_valid
  end
end
