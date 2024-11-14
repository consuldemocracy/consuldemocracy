require "rails_helper"

describe Admin::ProposalsController, :admin do
  describe "PATCH select" do
    let(:proposal) { create(:proposal) }

    it "selects the proposal" do
      expect do
        patch :select, xhr: true, params: { id: proposal.id }
      end.to change { proposal.reload.selected? }.from(false).to(true)

      expect(response).to be_successful
    end

    it "does not modify already selected proposals" do
      proposal.update!(selected: true)

      expect do
        patch :select, xhr: true, params: { id: proposal.id }
      end.not_to change { proposal.reload.selected? }
    end

    it "redirects admins without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = admin_proposals_path

      patch :select, params: { id: proposal.id }

      expect(response).to redirect_to admin_proposals_path
      expect(flash[:notice]).to eq "Proposal updated successfully."
    end
  end

  describe "PATCH deselect" do
    let(:proposal) { create(:proposal, :selected) }

    it "deselects the proposal" do
      expect do
        patch :deselect, xhr: true, params: { id: proposal.id }
      end.to change { proposal.reload.selected? }.from(true).to(false)

      expect(response).to be_successful
    end

    it "does not modify non-selected proposals" do
      proposal.update!(selected: false)

      expect do
        patch :deselect, xhr: true, params: { id: proposal.id }
      end.not_to change { proposal.reload.selected? }
    end

    it "redirects admins without JavaScript to the same page" do
      request.env["HTTP_REFERER"] = admin_proposals_path

      patch :deselect, params: { id: proposal.id }

      expect(response).to redirect_to admin_proposals_path
      expect(flash[:notice]).to eq "Proposal updated successfully."
    end
  end
end
