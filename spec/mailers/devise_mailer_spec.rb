# coding: utf-8
require "rails_helper"

describe DeviseMailer do
  describe "#confirmation_instructions" do
    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")

      email = I18n.with_locale :en do
        described_class.confirmation_instructions(user, "ABC")
      end

      expect(email.subject).to include("confirmación")
    end
  end
end
