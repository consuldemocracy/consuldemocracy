require "rails_helper"

RSpec.describe Identity, type: :model do
  let(:identity) { build(:identity) }

  it "is valid" do
    expect(identity).to be_valid
  end
end

# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  provider   :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
