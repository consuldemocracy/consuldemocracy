require 'rails_helper'

describe Comment do

  let(:comment) { build(:comment) }

  it "should be valid" do
    expect(comment).to be_valid
  end

  it "should update cache_counter in debate after hide" do
    debate  = create(:debate)
    comment = create(:comment, commentable: debate)

    expect(debate.reload.comments_count).to eq(1)
    comment.hide
    expect(debate.reload.comments_count).to eq(0)
  end

  describe "#as_administrator?" do
    it "should be true if comment has administrator_id, false otherway" do
      expect(comment).not_to be_as_administrator

      comment.administrator_id = 33

      expect(comment).to be_as_administrator
    end
  end

  describe "#as_moderator?" do
    it "should be true if comment has moderator_id, false otherway" do
      expect(comment).not_to be_as_moderator

      comment.moderator_id = 21

      expect(comment).to be_as_moderator
    end
  end

  describe "cache" do
    let(:comment) { create(:comment) }

    it "should expire cache when it has a new vote" do
      expect { create(:vote, votable: comment) }
      .to change { comment.updated_at }
    end

    it "should expire cache when hidden" do
      expect { comment.hide }
      .to change { comment.updated_at }
    end

    it "should expire cache when the author is hidden" do
      expect { comment.user.hide }
      .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end

    it "should expire cache when the author changes" do
      expect { comment.user.update(username: "Isabel") }
      .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end

    it "should expire cache when the author's organization get verified" do
      create(:organization, user: comment.user)
      expect { comment.user.organization.verify }
      .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end
  end
end
