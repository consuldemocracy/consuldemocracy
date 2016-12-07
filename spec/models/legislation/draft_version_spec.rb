require 'rails_helper'

RSpec.describe Legislation::DraftVersion, type: :model do
    let(:legislation_draft_version) { build(:legislation_draft_version) }

  it "should be valid" do
    expect(legislation_draft_version).to be_valid
  end
end
