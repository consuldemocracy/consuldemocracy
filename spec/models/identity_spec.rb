require 'rails_helper'

RSpec.describe Identity, type: :model do
  let(:identity) { build(:identity) }

  it "should be valid" do
    expect(identity).to be_valid
  end
end
