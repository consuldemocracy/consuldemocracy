require "rails_helper"

describe ApplicationHelper do

  describe "#author_of?" do
    it "is true if user is the author" do
      user = create(:user)
      proposal = create(:proposal, author: user)
      expect(author_of?(proposal, user)).to eq true
    end

    it "is false if user is not the author" do
      user = create(:user)
      proposal = create(:proposal)
      expect(author_of?(proposal, user)).to eq false
    end

    it "is false if user or authorable is nil" do
      user = create(:user)
      proposal = create(:proposal)

      expect(author_of?(nil, user)).to eq false
      expect(author_of?(proposal, nil)).to eq false
    end
  end

end