require "rails_helper"

describe Admin::NewsletterRecipientsController, type: :request do
  before do
    admin = create(:administrator, user: create(:user, email: "admin@consul.dev"))
    sign_in(admin.user)
  end

  describe "GET #index" do
    let!(:active_recipient) { create(:newsletter_recipient, :with_confirmed) }
    let!(:inactive_recipient_1) { create(:newsletter_recipient, active: true, confirmed_at: nil) }
    let!(:inactive_recipient_2) { create(:newsletter_recipient, active: false, confirmed_at: Time.zone.now) }

    it "renders all recipients when no filter is provided" do
      get admin_newsletter_recipients_path

      expect(response).to be_successful
      expect(response.body).to include(active_recipient.email)
      expect(response.body).not_to include(inactive_recipient_1.email)
      expect(response.body).not_to include(inactive_recipient_2.email)
    end

    it "filters by active" do
      get admin_newsletter_recipients_path, params: { filter: "active" }

      expect(response).to be_successful
      expect(response.body).to include(active_recipient.email)
      expect(response.body).not_to include(inactive_recipient_1.email)
      expect(response.body).not_to include(inactive_recipient_2.email)
    end

    it "filters by inactive" do
      get admin_newsletter_recipients_path, params: { filter: "inactive" }

      expect(response).to be_successful
      expect(response.body).not_to include(active_recipient.email)
      expect(response.body).not_to include(inactive_recipient_1.email)
      expect(response.body).to include(inactive_recipient_2.email)
    end

    it "responds with JS format" do
      get admin_newsletter_recipients_path, xhr: true

      expect(response).to be_successful
      expect(response.media_type).to eq("text/javascript")
    end
  end
end
