require "rails_helper"

describe Admin::ProposalDashboardActionsHelper do
  describe "active_human_readable" do
    context "when active is true" do
      it "returns label for active state" do
        expect(active_human_readable(true)).to eq(t("admin.dashboard.actions.index.active"))
      end
    end

    context "when active is false" do
      it "returns label for inactive state" do
        expect(active_human_readable(false)).to eq(t("admin.dashboard.actions.index.inactive"))
      end
    end
  end
end
