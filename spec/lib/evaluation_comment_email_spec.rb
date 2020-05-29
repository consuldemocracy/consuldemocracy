require "rails_helper"

describe EvaluationCommentEmail do
  let(:author)        { create(:user) }
  let(:administrator) { create(:administrator) }
  let(:investment)    { create(:budget_investment, author: author, administrator: administrator) }
  let(:commenter)     { create(:user, email: "email@commenter.org") }
  let(:comment)       { create(:comment, commentable: investment, user: commenter) }
  let(:comment_email) { EvaluationCommentEmail.new(comment) }

  describe "#commentable" do
    it "returns the commentable object that contains the replied comment" do
      expect(comment_email.commentable).to eq investment
    end
  end

  describe "#to" do
    it "returns an array of users related to investment" do
      expect(comment_email.to).to eq [administrator]
    end

    it "returns empty array if commentable not exists" do
      allow(comment).to receive(:commentable).and_return(nil)
      expect(comment_email.to).to eq []
    end

    it "returns empty array if not associated users" do
      allow(investment).to receive(:admin_and_valuator_users_associated).and_return([])
      expect(comment_email.to).to eq []
    end
  end

  describe "#subject" do
    it "returns the translation for a evaluation comment email subject" do
      expect(comment_email.subject).to eq "New evaluation comment"
    end
  end

  describe "#can_be_sent?" do
    it "returns true if investment has any associated users" do
      expect(comment_email.can_be_sent?).to be true
    end

    it "returns false if the comment doesn't exist" do
      comment.commentable = nil

      expect(comment_email.can_be_sent?).to be false
    end

    it "returns false if recipients are empty" do
      investment.administrator = nil
      expect(comment_email.can_be_sent?).to be false
    end
  end
end
