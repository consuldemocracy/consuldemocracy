require "rails_helper"

describe NewsletterRecipientsController do
  describe "POST #create" do
    let(:valid_params) { { newsletter_recipient: { email: "user@example.com" }} }
    let(:invalid_params) { { newsletter_recipient: { email: "" }} }

    it "creates a new newsletter recipient with valid params" do
      expect do
        post :create, xhr: true, params: valid_params
      end.to change(NewsletterRecipient, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("You have successfully subscribed!")
    end

    it "does not create newsletter recipient with invalid params" do
      expect do
        post :create, xhr: true, params: invalid_params
      end.not_to change(NewsletterRecipient, :count)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "GET #edit" do
    let!(:recipient) { create(:newsletter_recipient, confirmed_at: nil) }

    it "confirms email if token is valid" do
      get :edit, params: { token: recipient.token }

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Email is successfully confirmed.")
      expect(recipient.reload.confirmed_at).to be_present
    end

    it "redirects with error if token is invalid" do
      get :edit, params: { token: "wrong-token" }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE #destroy" do
    let!(:recipient) { create(:newsletter_recipient) }

    it "destroys recipient if token is valid" do
      expect do
        delete :destroy, params: { token: recipient.token }
      end.to change(NewsletterRecipient, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end

    it "redirects token is invalid" do
      expect do
        delete :destroy, params: { token: "wrong-token" }
      end.not_to change(NewsletterRecipient, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
