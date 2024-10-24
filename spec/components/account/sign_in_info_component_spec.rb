require "rails_helper"

describe Account::SignInInfoComponent do
  let(:account) { create(:user, last_sign_in_at: Date.current, last_sign_in_ip: "1.2.3.4") }

  context "Security secret for render last sign in is enabled" do
    it "shows a sign in info" do
      allow(Rails.application).to receive(:secrets).and_return(ActiveSupport::OrderedOptions.new.merge(
        security: { last_sign_in: true }
      ))

      render_inline Account::SignInInfoComponent.new(account)

      expect(page).to have_content "Last login:"
      expect(page).to have_content "from IP"
    end
  end

  context "Security secret for render last sign in is disabled" do
    it "does not show sign in info" do
      render_inline Account::SignInInfoComponent.new(account)

      expect(page).not_to be_rendered
    end
  end
end
