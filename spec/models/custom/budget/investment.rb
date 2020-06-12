require "rails_helper"

describe Budget::Investment do
  describe "#ballotable_by_geozone?" do
    describe "Final Voting with geozone" do
      describe "Permissions" do
        let(:geozone)     { create(:geozone) }
        let(:budget)      { create(:budget) }
        let(:heading)     { create(:budget_heading, budget: budget, geozone: geozone) }
        let(:user)        { create(:user, :level_two, geozone: geozone) }
        let(:luser)       { create(:user) }
        let(:ballot)      { create(:budget_ballot, budget: budget) }
        let(:investment)  { create(:budget_investment, :selected, budget: budget, heading: heading) }

        describe "#reason_for_not_being_ballotable_by" do
          it "accepts users when heading geozone is blank" do
            budget.phase = "balloting"
            group = create(:budget_group, budget: budget)
            heading_without_geozone = create(:budget_heading, group: group)
            investment = create(
              :budget_investment,
              :selected,
              budget: budget,
              heading: heading_without_geozone
            )
            ballot = create(
              :budget_ballot,
              user: user,
              budget: budget,
              investments: [investment]
            )
            expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to be_nil
          end

          it "rejects users when heading geozone is present and user geozone is not the same" do
            budget.phase = "balloting"
            heading.geozone = create(:geozone, name: "Boston")
            user.geozone =  create(:geozone, name: "California")
            expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:invalid_geozone)
          end

          it "accepts users when heading geozone is present and user geozone is the same" do
            budget.phase = "balloting"
            expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to be_nil
          end
        end
      end
    end
  end
end
