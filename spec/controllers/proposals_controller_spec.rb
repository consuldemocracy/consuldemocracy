require "rails_helper"

describe ProposalsController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.proposals"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "PUT update" do
    let(:file) { Rails.root.join("spec/hacked") }

    before do
      File.delete(file) if File.exist?(file)
      InvisibleCaptcha.timestamp_enabled = false
    end

    after { InvisibleCaptcha.timestamp_enabled = true }

    it "ignores malicious cached attachments with remote storages" do
      allow_any_instance_of(Image).to receive(:filesystem_storage?).and_return(false)
      user = create(:user)
      proposal = create(:proposal, author: user)
      sign_in user

      begin
        put :update, params: {
          id: proposal,
          proposal: {
            image_attributes: {
              title: "Hacked!",
              user_id: user.id,
              cached_attachment: "| touch #{file}"
            }
          }
        }
      rescue StandardError
      ensure
        expect(file).not_to exist
      end
    end
  end
end
