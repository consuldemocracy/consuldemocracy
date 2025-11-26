require "rails_helper"

describe Proposals::SupportsComponent do
  describe "#progress_bar_percentage" do
    it "is 0 if there are no votes" do
      proposal = Proposal.new

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".meter[style*='width: 0%']"
    end

    it "is between 1 and 100 if there are votes but less than needed" do
      proposal = Proposal.new(cached_votes_up: Proposal.votes_needed_for_success / 2)

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".meter[style*='width: 50%']"
    end

    it "is 100 if there are more votes than needed" do
      proposal = Proposal.new(cached_votes_up: Proposal.votes_needed_for_success * 2)

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".meter[style*='width: 100%']"
    end
  end

  describe "#supports_percentage" do
    it "is 0 if there are no votes" do
      proposal = Proposal.new

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".percentage", text: "0%"
    end

    it "is between 0.1 from 1 to 0.1% of needed votes" do
      proposal = Proposal.new(cached_votes_up: 1)

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".percentage", text: "0.1%"
    end

    it "is between 1 and 100 if there are votes but less than needed" do
      proposal = Proposal.new(cached_votes_up: Proposal.votes_needed_for_success / 2)

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".percentage", text: "50%"
    end

    it "is 100 if there are more votes than needed" do
      proposal = Proposal.new(cached_votes_up: Proposal.votes_needed_for_success * 2)

      render_inline Proposals::SupportsComponent.new(proposal)

      expect(page).to have_css ".percentage", text: "100%"
    end
  end
end
