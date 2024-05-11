require "rails_helper"

describe "polls tasks" do
  let(:poll) { create(:poll) }
  let(:user) { create(:user, :level_two) }

  describe "polls:remove_duplicate_voters" do
    before { Rake::Task["polls:remove_duplicate_voters"].reenable }

    it "removes duplicate voters" do
      second_user = create(:user, :level_two)

      voter = create(:poll_voter, poll: poll, user: user)
      second_voter = create(:poll_voter, poll: poll, user: second_user)
      other_user_voter = create(:poll_voter, poll: poll, user: create(:user, :level_two))
      other_poll_voter = create(:poll_voter, poll: create(:poll), user: user)

      duplicate = build(:poll_voter, poll: poll, user: user)
      another_duplicate = build(:poll_voter, poll: poll, user: user)
      second_user_duplicate = build(:poll_voter, poll: poll, user: second_user)

      duplicate.save!(validate: false)
      another_duplicate.save!(validate: false)
      second_user_duplicate.save!(validate: false)

      expect(Poll::Voter.count).to eq 7

      Rake.application.invoke_task("polls:remove_duplicate_voters")

      expect(Poll::Voter.count).to eq 4
      expect(Poll::Voter.all).to match_array [voter, second_voter, other_user_voter, other_poll_voter]
    end

    it "removes duplicate voters on tenants" do
      create(:tenant, schema: "voters")

      Tenant.switch("voters") do
        poll = create(:poll)
        user = create(:user, :level_two)

        create(:poll_voter, poll: poll, user: user)
        build(:poll_voter, poll: poll, user: user).save!(validate: false)

        expect(Poll::Voter.count).to eq 2
      end

      Rake.application.invoke_task("polls:remove_duplicate_voters")

      Tenant.switch("voters") do
        expect(Poll::Voter.count).to eq 1
      end
    end
  end
end
