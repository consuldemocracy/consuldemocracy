require 'rails_helper'

RSpec.describe Community, type: :model do

  it "should be valid when create proposal" do
    proposal = create(:proposal)

    expect(proposal.community).to be_valid
  end
end
