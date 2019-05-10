require "rails_helper"

describe Poll::BoothAssignment do
  let(:poll){create(:poll)}
  let(:booth){create(:poll_booth)}
  let(:booth1){create(:poll_booth)}

  it "checks if there are shifts" do
    assignment_with_shifts = create(:poll_booth_assignment, poll: poll, booth: booth)
    assignment_without_shifts = create(:poll_booth_assignment, poll: poll, booth: booth1)
    officer = create(:poll_officer)
    create(:poll_officer_assignment, officer: officer, booth_assignment: assignment_with_shifts)
    create(:poll_shift, booth: booth, officer: officer)

    expect(assignment_with_shifts.shifts?).to eq(true)
    expect(assignment_without_shifts.shifts?).to eq(false)
  end

  it "deletes shifts associated to booth assignments" do
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    officer = create(:poll_officer)
    create(:poll_officer_assignment, officer: officer, booth_assignment: assignment)
    create(:poll_shift, booth: booth, officer: officer)

    assignment.destroy

    expect(Poll::Shift.all.count).to eq(0)
  end
end
