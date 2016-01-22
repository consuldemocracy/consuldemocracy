# coding: utf-8
require 'rails_helper'

describe DeviseMailer do
  describe "#confirmation_instructions" do
    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")

      email = I18n.with_locale :en do
        DeviseMailer.confirmation_instructions(user, "ABC")
      end

      expect(email.subject).to include("confirmación")
    end
  end
end
