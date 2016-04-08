require 'rails_helper'

describe SpendingProposalsHelper do

  describe "supports_confirm_for_current_user" do

    let(:forum)   { create(:forum) }
    let(:geozone) { create(:geozone) }

    it "returns delegation message" do
      user = create(:user, representative: forum)
      spending_proposal = create(:spending_proposal)
      set_stubs(user, spending_proposal)

      expect(confirmation(spending_proposal)).to eq(
            {confirm: "If you vote you will stop delegating. "})
    end

    it "returns delegation message once" do
      user = create(:user, representative: forum, accepted_delegation_alert: true)
      spending_proposal = create(:spending_proposal)
      set_stubs(user, spending_proposal)

      expect(confirmation(spending_proposal)).to eq(nil)
    end


    it "returns geozone lockdown message" do
      user = create(:user)
      spending_proposal = create(:spending_proposal, geozone: geozone)
      set_stubs(user, spending_proposal)

      expect(confirmation(spending_proposal)).to eq(
            {confirm: "Everyone can support the proposal of the city and one district of their choice, If you accept you support this proposal and only can support the proposals for #{geozone.name}. This district can't change later. Do you want support this proposal and select this district?"})
    end

    it "returns delegation message and geozone lockdown message" do
      user = create(:user, representative: forum)
      spending_proposal = create(:spending_proposal, geozone: geozone)
      set_stubs(user, spending_proposal)

      expect(confirmation(spending_proposal)).to eq(
            {confirm: "If you vote you will stop delegating. Everyone can support the proposal of the city and one district of their choice, If you accept you support this proposal and only can support the proposals for #{geozone.name}. This district can't change later. Do you want support this proposal and select this district?"})
    end

    it "retuns nil" do
      user = create(:user, supported_spending_proposals_geozone_id: geozone.id)
      spending_proposal = create(:spending_proposal, geozone: geozone)
      create(:vote, votable: spending_proposal, voter: user)
      set_stubs(user, spending_proposal)

      expect(confirmation(spending_proposal)).to eq(nil)
    end
  end

end

def set_stubs(user, spending_proposal)
  allow(helper).to receive(:current_user).and_return(user)
  allow(helper).to receive(:spending_proposal).and_return(spending_proposal)
end

def confirmation(spending_proposal)
  helper.supports_confirm_for_current_user(spending_proposal)
end