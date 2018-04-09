# coding: utf-8
require 'rails_helper'

describe Debate do

  describe "#destroyable" do

    it "is destroyed if debate has no votes yet and no comments yet" do
      debate = create(:debate)
      expect(debate.total_votes).to eq(0)
      expect(debate.comments.count).to eq(0)
      expect(debate.destroyable?).to be true
      expect do
           debate.destroy
      end.to change { Debate.count }.by(-1)
    end

    it "isnt destroyed if debate has 1 vote" do
      debate = create(:debate)
      create_list(:vote, 1, votable: debate)
      expect(debate.total_votes).to eq(1)
      expect(debate.destroyable?).to be false
    end

    it "isnt destroyed if debate has 1 comment" do
      debate = create(:debate)
      Comment.create(user: create(:user), commentable: debate, body: 'tirlipinpin')
      expect(debate.comments.count).to eq(1)
      expect(debate.destroyable?).to be false
    end
  end

  describe "#destroyable_by?" do
    let(:debate) { create(:debate) }

    it "is true if user is the author and debate is destroyable" do
      expect(debate.destroyable_by?(debate.author)).to be true
    end

    it "is false if debate is not destroyable" do
      create_list(:vote, 2, votable: debate)
      expect(debate.destroyable_by?(debate.author)).to be false
    end

    it "is false if user is not the author" do
      expect(debate.destroyable_by?(create(:user))).to be false
    end
  end

end
