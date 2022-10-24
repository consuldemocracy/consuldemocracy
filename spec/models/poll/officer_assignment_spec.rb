require "rails_helper"

describe Poll::OfficerAssignment do
  it "logs user data on creation" do
    user = create(:user, username: "Larry Bird", email: "larry@lege.nd")
    officer = create(:poll_officer, user: user)

    oa = create(:poll_officer_assignment, officer: officer)

    expect(oa.reload.user_data_log).to eq "#{user.id} - Larry Bird (larry@lege.nd)"
  end
end

# == Schema Information
#
# Table name: poll_officer_assignments
#
#  id                  :integer          not null, primary key
#  booth_assignment_id :integer
#  officer_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  date                :date             not null
#  final               :boolean          default(FALSE)
#  user_data_log       :string           default("")
#
