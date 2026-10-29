require "rails_helper"

describe Legislation::Proposals::VotesController do
  describe "POST /legislation/processes/:process_id/proposals/:legislation_proposal_id/votes" do
    it "does not create two records with two simultaneous requests", :race_condition do
      proposal = create(:legislation_proposal)
      user = create(:user, :level_two)

      sign_in(user)
      path = legislation_process_legislation_proposal_votes_path(proposal.process, proposal)

      2.times.map do
        Thread.new do
          post path, xhr: true, params: { value: "yes" }
        end
      end.each(&:join)

      expect(Vote.where(voter: user, votable: proposal).count).to eq 1
    end
  end
end
