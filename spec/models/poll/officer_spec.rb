require "rails_helper"

describe Poll::Officer do

  describe "#voting_days_assigned_polls" do
    it "returns all polls with this officer assigned during voting days" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)
      poll_3 = create(:poll)

      booth_assignment_1a = create(:poll_booth_assignment, poll: poll_1)
      booth_assignment_1b = create(:poll_booth_assignment, poll: poll_1)
      booth_assignment_2  = create(:poll_booth_assignment, poll: poll_2)

      create(:poll_officer_assignment, booth_assignment: booth_assignment_1a, officer: officer, date: poll_1.starts_at)
      create(:poll_officer_assignment, booth_assignment: booth_assignment_1b, officer: officer, date: poll_1.ends_at)
      create(:poll_officer_assignment, booth_assignment: booth_assignment_2, officer: officer)

      assigned_polls = officer.voting_days_assigned_polls
      expect(assigned_polls.size).to eq 2
      expect(assigned_polls.include?(poll_1)).to eq(true)
      expect(assigned_polls.include?(poll_2)).to eq(true)
      expect(assigned_polls.include?(poll_3)).to eq(false)
    end

    it "does not return polls with this officer assigned for final recount/results" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)

      booth_assignment_1 = create(:poll_booth_assignment, poll: poll_1)
      booth_assignment_2 = create(:poll_booth_assignment, poll: poll_2)

      create(:poll_officer_assignment, booth_assignment: booth_assignment_1, officer: officer, date: poll_1.starts_at)
      create(:poll_officer_assignment, booth_assignment: booth_assignment_2, officer: officer, final: true)

      assigned_polls = officer.voting_days_assigned_polls
      expect(assigned_polls.size).to eq 1
      expect(assigned_polls.include?(poll_1)).to eq(true)
      expect(assigned_polls.include?(poll_2)).to eq(false)
    end

    it "returns polls ordered by end date (desc)" do
      officer = create(:poll_officer)

      poll_1 = create(:poll, ends_at: 1.day.ago)
      poll_2 = create(:poll, ends_at: 10.days.from_now)
      poll_3 = create(:poll, ends_at: 10.days.ago)

      [poll_1, poll_2, poll_3].each do |p|
        create(:poll_officer_assignment, officer: officer, booth_assignment: create(:poll_booth_assignment, poll: p))
      end

      assigned_polls = officer.voting_days_assigned_polls

      expect(assigned_polls.first).to eq(poll_2)
      expect(assigned_polls.second).to eq(poll_1)
      expect(assigned_polls.last).to eq(poll_3)
    end
  end

  describe "#final_days_assigned_polls" do
    it "returns all polls with this officer assigned for final recount/results" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)
      poll_3 = create(:poll)

      booth_assignment_1a = create(:poll_booth_assignment, poll: poll_1)
      booth_assignment_1b = create(:poll_booth_assignment, poll: poll_1)
      booth_assignment_2  = create(:poll_booth_assignment, poll: poll_2)

      create(:poll_officer_assignment, booth_assignment: booth_assignment_1a, officer: officer, date: poll_1.starts_at, final: true)
      create(:poll_officer_assignment, booth_assignment: booth_assignment_1b, officer: officer, date: poll_1.ends_at, final: true)
      create(:poll_officer_assignment, booth_assignment: booth_assignment_2, officer: officer, final: true)

      assigned_polls = officer.final_days_assigned_polls
      expect(assigned_polls.size).to eq 2
      expect(assigned_polls.include?(poll_1)).to eq(true)
      expect(assigned_polls.include?(poll_2)).to eq(true)
      expect(assigned_polls.include?(poll_3)).to eq(false)
    end

    it "does not return polls with this officer assigned for voting days" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)

      booth_assignment_1 = create(:poll_booth_assignment, poll: poll_1)
      booth_assignment_2 = create(:poll_booth_assignment, poll: poll_2)

      create(:poll_officer_assignment, booth_assignment: booth_assignment_1, officer: officer, date: poll_1.starts_at)
      create(:poll_officer_assignment, booth_assignment: booth_assignment_2, officer: officer, final: true)

      assigned_polls = officer.final_days_assigned_polls
      expect(assigned_polls.size).to eq 1
      expect(assigned_polls.include?(poll_1)).to eq(false)
      expect(assigned_polls.include?(poll_2)).to eq(true)
    end

    it "returns polls ordered by end date (desc)" do
      officer = create(:poll_officer)

      poll_1 = create(:poll, ends_at: 1.day.ago)
      poll_2 = create(:poll, ends_at: 10.days.from_now)
      poll_3 = create(:poll, ends_at: 10.days.ago)

      [poll_1, poll_2, poll_3].each do |p|
        create(:poll_officer_assignment, officer: officer, booth_assignment: create(:poll_booth_assignment, poll: p), final: true)
      end

      assigned_polls = officer.final_days_assigned_polls

      expect(assigned_polls.first).to eq(poll_2)
      expect(assigned_polls.second).to eq(poll_1)
      expect(assigned_polls.last).to eq(poll_3)
    end
  end
end
