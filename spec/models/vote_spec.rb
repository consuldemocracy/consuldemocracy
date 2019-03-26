require "rails_helper"

describe Vote do

  describe "#for_debates" do
    it "does not returns votes for other votables" do
      debate = create(:debate)
      comment = create(:comment)
      create(:vote, votable: comment)

      expect(described_class.for_debates(debate).count).to eq(0)
    end

    it "returns votes only for debates in parameters" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      create(:vote, votable: debate1)

      expect(described_class.for_debates(debate1).count).to eq(1)
      expect(described_class.for_debates(debate2).count).to eq(0)
    end

    it "accepts more than 1 debate" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, votable: debate1)
      create(:vote, votable: debate3)

      expect(described_class.for_debates([debate1, debate2]).count).to eq(1)
    end
  end

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

      expect(described_class.public_for_api).to include(vote)
    end

    it "blocks votes on hidden debates" do
      debate = create(:debate, :hidden)
      vote = create(:vote, votable: debate)

      expect(described_class.public_for_api).not_to include(vote)
    end

    it "returns votes on proposals" do
      proposal = create(:proposal)
      vote = create(:vote, votable: proposal)

      expect(described_class.public_for_api).to include(vote)
    end

    it "blocks votes on hidden proposals" do
      proposal = create(:proposal, :hidden)
      vote = create(:vote, votable: proposal)

      expect(described_class.public_for_api).not_to include(vote)
    end

    it "returns votes on comments" do
      comment = create(:comment)
      vote = create(:vote, votable: comment)

      expect(described_class.public_for_api).to include(vote)
    end

    it "blocks votes on hidden comments" do
      comment = create(:comment, :hidden)
      vote = create(:vote, votable: comment)

      expect(described_class.public_for_api).not_to include(vote)
    end

    it "blocks votes on comments on hidden proposals" do
      hidden_proposal = create(:proposal, :hidden)
      comment_on_hidden_proposal = create(:comment, commentable: hidden_proposal)
      vote = create(:vote, votable: comment_on_hidden_proposal)

      expect(described_class.public_for_api).not_to include(vote)
    end

    it "blocks votes on comments on hidden debates" do
      hidden_debate = create(:debate, :hidden)
      comment_on_hidden_debate = create(:comment, commentable: hidden_debate)
      vote = create(:vote, votable: comment_on_hidden_debate)

      expect(described_class.public_for_api).not_to include(vote)
    end

    it "blocks any other kind of votes" do
      spending_proposal = create(:spending_proposal)
      vote = create(:vote, votable: spending_proposal)

      expect(described_class.public_for_api).not_to include(vote)
    end

    it "blocks votes without votable" do
      vote = build(:vote, votable: nil).save!(validate: false)

      expect(described_class.public_for_api).not_to include(vote)
    end
  end
end
