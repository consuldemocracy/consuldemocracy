require 'rails_helper'

describe Comment do

  let(:comment) { build(:comment) }

  it "should be valid" do
    expect(comment).to be_valid
  end

  describe "#children_count" do
    let(:comment) { create(:comment) }
    let(:debate)  { comment.debate }

    it "should count first level children" do
      parent = comment

      3.times do
        create(:comment, commentable: debate).
        move_to_child_of(parent)
        parent = parent.children.first
      end

      expect(comment.children_count).to eq(1)
      expect(debate.comment_threads.count).to eq(4)
    end

    it "should increase children count" do
      expect do
        create(:comment, commentable: debate).
        move_to_child_of(comment)
      end.to change { comment.children_count }.from(0).to(1)
    end

    it "should decrease children count" do
      new_comment = create(:comment, commentable: debate).move_to_child_of(comment)

      expect { new_comment.destroy }.to change { comment.children_count }.from(1).to(0)
    end
  end
end
