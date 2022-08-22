require "rails_helper"

describe Vote do
  describe "#value" do
    it "returns vote flag" do
      vote = create(:vote, vote_flag: true)
      expect(vote.value).to eq(true)

      vote = create(:vote, vote_flag: false)
      expect(vote.value).to eq(false)
    end
  end

  describe "public_for_api scope" do
    it "returns votes on debates" do
      debate = create(:debate)
      vote = create(:vote, votable: debate)

      expect(Vote.public_for_api).to eq [vote]
    end

    it "blocks votes on hidden debates" do
      create(:vote, votable: create(:debate, :hidden))

      expect(Vote.public_for_api).to be_empty
    end

    it "returns votes on proposals" do
      proposal = create(:proposal)
      vote = create(:vote, votable: proposal)

      expect(Vote.public_for_api).to eq [vote]
    end

    it "blocks votes on hidden proposals" do
      create(:vote, votable: create(:proposal, :hidden))

      expect(Vote.public_for_api).to be_empty
    end

    it "returns votes on comments" do
      comment = create(:comment)
      vote = create(:vote, votable: comment)

      expect(Vote.public_for_api).to eq [vote]
    end

    it "blocks votes on hidden comments" do
      create(:vote, votable: create(:comment, :hidden))

      expect(Vote.public_for_api).to be_empty
    end

    it "blocks votes on comments on hidden proposals" do
      hidden_proposal = create(:proposal, :hidden)
      comment_on_hidden_proposal = create(:comment, commentable: hidden_proposal)
      create(:vote, votable: comment_on_hidden_proposal)

      expect(Vote.public_for_api).to be_empty
    end

    it "blocks votes on comments on hidden debates" do
      hidden_debate = create(:debate, :hidden)
      comment_on_hidden_debate = create(:comment, commentable: hidden_debate)
      create(:vote, votable: comment_on_hidden_debate)

      expect(Vote.public_for_api).to be_empty
    end

    it "blocks any other kind of votes" do
      create(:vote, votable: create(:budget_investment))

      expect(Vote.public_for_api).to be_empty
    end

    it "blocks votes without votable" do
      build(:vote, votable: nil).save!(validate: false)

      expect(Vote.public_for_api).to be_empty
    end
  end
end
