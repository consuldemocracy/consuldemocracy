require 'rails_helper'

describe Activity do
  let(:author) { create :user }
  let(:activity) { create :activity, user: author }

  describe "#username" do
    it "returns the username of the activity's author" do
      expect(activity.username).to eq author.username
    end
  end

  describe "#made_by?" do
    it "returns true if activity was made by user" do
      expect(activity.made_by?(author)).to be true
    end

    it "returns false if activity was not made by user" do
      not_author = create :user
      expect(activity.made_by?(not_author)).to be false
    end
  end

end
