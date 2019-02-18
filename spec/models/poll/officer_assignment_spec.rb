require "rails_helper"

describe Poll::OfficerAssignment do
  it "logs user data on creation" do
    user = create(:user, username: "Larry Bird", email: "larry@lege.nd")
    officer = create(:poll_officer, user: user)

    oa = create(:poll_officer_assignment, officer: officer)

    expect(oa.reload.user_data_log).to eq "#{user.id} - Larry Bird (larry@lege.nd)"
  end
end
