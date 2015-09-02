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

  describe "#children_count" do
    let(:comment) { create(:comment) }
    let(:debate)  { comment.debate }

    it "should count first level children" do
      parent = comment

      3.times do
        create(:comment, commentable: debate, parent: parent)
        parent = parent.children.first
      end

      expect(comment.children_count).to eq(1)
      expect(debate.comments.count).to eq(4)
    end

    it "should increase children count" do
      expect do
        create(:comment, commentable: debate, parent: comment)
      end.to change { comment.children_count }.from(0).to(1)
    end

    it "should decrease children count" do
      new_comment = create(:comment, commentable: debate, parent: comment)

      expect { new_comment.destroy }.to change { comment.children_count }.from(1).to(0)
    end
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
end
