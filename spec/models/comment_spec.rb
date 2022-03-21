require "rails_helper"

describe Comment do
  let(:comment) { build(:comment) }

  it_behaves_like "has_public_author"
  it_behaves_like "globalizable", :comment
  it_behaves_like "acts as paranoid", :comment

  it "is valid" do
    expect(comment).to be_valid
  end

  it "dynamically validates the commentable types" do
    stub_const("#{Comment}::COMMENTABLE_TYPES", %w[Debate])

    expect(build(:comment, commentable: create(:debate))).to be_valid
    expect(build(:comment, commentable: create(:proposal))).not_to be_valid
  end

  it "updates cache_counter in debate after hide and restore" do
    debate  = create(:debate)
    comment = create(:comment, commentable: debate)

    expect(debate.reload.comments_count).to eq(1)
    comment.hide
    expect(debate.reload.comments_count).to eq(0)
    comment.restore
    expect(debate.reload.comments_count).to eq(1)
  end

  describe "#as_administrator?" do
    it "is true if comment has administrator_id, false otherway" do
      expect(comment).not_to be_as_administrator

      comment.administrator_id = 33

      expect(comment).to be_as_administrator
    end
  end

  describe "#as_moderator?" do
    it "is true if comment has moderator_id, false otherway" do
      expect(comment).not_to be_as_moderator

      comment.moderator_id = 21

      expect(comment).to be_as_moderator
    end
  end

  describe "#confidence_score" do
    it "takes into account percentage of total votes and total_positive and total negative votes" do
      comment = create(:comment, :with_confidence_score, cached_votes_up: 100, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(10000)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 0, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(0)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 75, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(3750)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 750, cached_votes_total: 1000)
      expect(comment.confidence_score).to eq(37500)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 10, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(-800)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 0, cached_votes_total: 0)
      expect(comment.confidence_score).to eq(1)
    end

    describe "actions which affect it" do
      let(:comment) { create(:comment, :with_confidence_score) }

      it "increases with like" do
        previous = comment.confidence_score
        5.times { comment.vote_by(voter: create(:user), vote: true) }
        expect(previous).to be < comment.confidence_score
      end

      it "decreases with dislikes" do
        comment.vote_by(voter: create(:user), vote: true)
        previous = comment.confidence_score
        3.times { comment.vote_by(voter: create(:user), vote: false) }
        expect(previous).to be > comment.confidence_score
      end
    end
  end

  describe "cache" do
    let(:comment) { create(:comment) }

    it "expires cache when it has a new vote" do
      expect { create(:vote, votable: comment) }.to change { comment.cache_version }
    end

    it "expires cache when hidden" do
      expect { comment.hide }.to change { comment.cache_version }
    end

    it "expires cache when the author is hidden" do
      expect { comment.user.hide }
      .to change { [comment.reload.cache_version, comment.author.cache_version] }
    end

    it "expires cache when the author is erased" do
      expect { comment.user.erase }
      .to change { [comment.reload.cache_version, comment.author.cache_version] }
    end

    it "expires cache when the author changes" do
      expect { comment.user.update(username: "Isabel") }
      .to change { [comment.reload.cache_version, comment.author.cache_version] }
    end

    it "expires cache when the author's organization get verified" do
      create(:organization, user: comment.user)
      expect { comment.user.organization.verify }
      .to change { [comment.reload.cache_version, comment.author.cache_version] }
    end
  end

  describe "#author_id?" do
    it "returns the user's id" do
      expect(comment.author_id).to eq(comment.user.id)
    end
  end

  describe "not_as_admin_or_moderator" do
    it "returns only comments posted as regular user" do
      comment1 = create(:comment)
      create(:comment, administrator_id: create(:administrator).id)
      create(:comment, moderator_id: create(:moderator).id)

      expect(Comment.not_as_admin_or_moderator).to eq [comment1]
    end
  end

  describe "public_for_api scope" do
    it "returns comments" do
      comment = create(:comment)

      expect(Comment.public_for_api).to eq [comment]
    end

    it "does not return hidden comments" do
      create(:comment, :hidden)

      expect(Comment.public_for_api).to be_empty
    end

    it "returns comments on debates" do
      comment = create(:comment, commentable: create(:debate))

      expect(Comment.public_for_api).to eq [comment]
    end

    it "does not return comments on hidden debates" do
      create(:comment, commentable: create(:debate, :hidden))

      expect(Comment.public_for_api).to be_empty
    end

    it "returns comments on proposals" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      expect(Comment.public_for_api).to eq [comment]
    end

    it "does not return comments on hidden proposals" do
      create(:comment, commentable: create(:proposal, :hidden))

      expect(Comment.public_for_api).to be_empty
    end

    it "does not return comments on elements which are not debates or proposals" do
      create(:comment, commentable: create(:budget_investment))

      expect(Comment.public_for_api).to be_empty
    end

    it "does not return comments with no commentable" do
      build(:comment, commentable: nil).save!(validate: false)

      expect(Comment.public_for_api).to be_empty
    end

    it "does not return internal valuation comments" do
      create(:comment, :valuation)

      expect(Comment.public_for_api).to be_empty
    end
  end
end
