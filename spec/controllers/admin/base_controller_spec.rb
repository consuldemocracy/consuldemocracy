require "rails_helper"

describe Admin::BaseController, :admin do
  controller do
    def index
      render plain: "Index"
    end
  end

  describe "#restrict_ip" do
    before do
      stub_secrets(security: { allowed_admin_ips: ["1.2.3.4", "5.6.7.8"] })
    end

    it "renders the content when the IP is allowed" do
      request.env["REMOTE_ADDR"] = "1.2.3.4"
      get :index

      expect(response).to be_successful
      expect(response.body).to eq "Index"
    end

    it "redirects to the root path when the IP isn't allowed" do
      request.env["REMOTE_ADDR"] = "9.10.11.12"
      get :index

      expect(response).to redirect_to root_path
      expect(flash[:alert]).to eq "Access denied. Your IP address is not allowed."
    end
  end
end
