require "rails_helper"

describe Mailer do
  describe "#comment" do
    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")
      proposal = create(:proposal, author: user)
      comment = create(:comment, commentable: proposal)

      email = I18n.with_locale :en do
        described_class.comment(comment)
      end

      expect(email.subject).to include("comentado")
    end

    it "reads the from address at runtime" do
      Setting["mailer_from_name"] = "New organization"
      Setting["mailer_from_address"] = "new@consul.dev"

      email = Mailer.comment(create(:comment))

      expect(email).to deliver_from "New organization <new@consul.dev>"
    end
  end
end
