# spec/controllers/two_factor_authentications_controller_spec.rb

require 'rails_helper'

RSpec.describe TwoFactorAuthenticationsController, type: :controller do
  # Include Devise test helpers to sign in users
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }

  # Sign in the user before each test in this context
  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show
      expect(response).to be_successful
    end

    it 'assigns a QR code to @qr_code' do
      get :show
      expect(assigns(:qr_code)).to be_present
    end

    it 'generates an otp_secret for the user if one is missing' do
      user.update!(otp_secret: nil)
      get :show
      user.reload
      expect(user.otp_secret).not_to be_nil
    end
  end

  describe 'POST #enable' do
    before do
      # Ensure the user has a secret to validate against
      user.generate_two_factor_secret_if_missing!
    end

    context 'with a valid OTP' do
      let(:valid_otp) { user.current_otp }

      it 'enables two-factor authentication for the user' do
        post :enable, params: { otp_attempt: valid_otp }
        user.reload
        expect(user.otp_required_for_login).to be(true)
      end

      it 'generates backup codes' do
        post :enable, params: { otp_attempt: valid_otp }
        user.reload
        expect(user.otp_backup_codes).not_to be_empty
      end

      it 'stores plain backup codes in the flash' do
        post :enable, params: { otp_attempt: valid_otp }
        expect(flash[:backup_codes]).to be_an(Array)
        expect(flash[:backup_codes].first).to be_a(String)
      end

      it 'redirects to the backup codes page' do
        post :enable, params: { otp_attempt: valid_otp }
        expect(response).to redirect_to(backup_codes_account_two_factor_authentication_path)
      end
    end

    context 'with an invalid OTP' do
      let(:invalid_otp) { '000000' }

      it 'does not enable two-factor authentication' do
        post :enable, params: { otp_attempt: invalid_otp }
        user.reload
        expect(user.otp_required_for_login).to be_falsy
      end

      it 'renders the show template' do
        post :enable, params: { otp_attempt: invalid_otp }
        expect(response).to render_template(:show)
      end

      it 'sets a flash alert message' do
        post :enable, params: { otp_attempt: invalid_otp }
        expect(flash.now[:alert]).to eq('Invalid OTP')
      end
    end
  end

  describe 'GET #backup_codes' do
    context 'when backup codes are available' do
      it 'returns a successful response' do
        # Stub the flash hash for this specific test to directly test the controller's logic
        allow(controller).to receive(:flash).and_return({ backup_codes: ['12345', '67890'] })
        get :backup_codes
        expect(response).to be_successful
      end
    end

    context 'when backup codes are not available' do
      it 'redirects to the account path' do
        # In this case, the flash is empty by default, so the redirect logic will be triggered
        get :backup_codes
        # Assuming you have a named route like `account_path`.
        # If not, change this to the correct path, e.g., `root_path`.
        expect(response).to redirect_to(account_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      user.enable_two_factor!
    end

    it 'disables two-factor authentication for the user' do
      delete :destroy
      user.reload
      # Your destroy action only sets otp_required_for_login to false
      expect(user.otp_required_for_login).to be(false)
    end
    
    it 'clears the otp_secret' do
      delete :destroy
      user.reload
      expect(user.otp_secret).to be_nil
    end

    it 'redirects to the root path' do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end

    it 'sets a flash notice message' do
      delete :destroy
      expect(flash[:notice]).to eq('Two-factor authentication disabled')
    end
  end
end
