require "rails_helper"

describe ReplyEmail do
  let(:debate)      { create(:debate) }
  let(:commenter)   { create(:user, email: "email@commenter.org") }
  let(:comment)     { create(:comment, commentable: debate, user: commenter) }
  let(:replier)     { create(:user) }
  let(:reply)       { create(:comment, commentable: debate, parent: comment, user: replier) }
  let(:reply_email) { ReplyEmail.new(reply) }

  describe "#commentable" do
    it "returns the commentable object that contains the replied comment" do
      expect(reply_email.commentable).to eq debate
    end
  end

  describe "#recipient" do
    it "returns the author of the replied comment" do
      expect(reply_email.recipient).to eq commenter
    end
  end

  describe "#to" do
    it "returns the author's email of the replied comment" do
      expect(reply_email.to).to eq "email@commenter.org"
    end
  end

  describe "#subject" do
    it "returns the translation for a reply email subject" do
      expect(reply_email.subject).to eq "Someone has responded to your comment"
    end
  end

  describe "#can_be_sent?" do
    it "returns true if comment and recipient exist" do
      expect(reply_email.can_be_sent?).to be true
    end

    it "returns false if the comment doesn't exist" do
      reply.commentable = nil

      expect(reply_email.can_be_sent?).to be false
    end

    it "returns false if the recipient doesn't exist" do
      reply.parent.author.really_destroy!

      expect(reply_email.can_be_sent?).to be false
    end
  end
end
