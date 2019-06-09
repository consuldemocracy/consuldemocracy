require "rails_helper"

describe Moderation::Legislation::ProposalsController do
  let!(:proposal) { create(:legislation_proposal) }
  let(:admin) { create(:administrator) }

  before do
    login_as(admin.user)
  end

  it "hides a legislation proposal" do
    expect do
      put hide_moderation_legislation_proposal_path(proposal)
    end.to change(Legislation::Proposal, :count).by(-1)
  end

end
