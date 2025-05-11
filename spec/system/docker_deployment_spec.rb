require "rails_helper"

RSpec.describe "Docker Deployment", type: :system do
  describe "Health Check" do
    it "returns 200 status code" do
      visit "/health"
      expect(page).to have_http_status(:ok)
      expect(page).to have_content('{"status":"ok"}')
    end
  end

  describe "Environment Configuration" do
    it "has required environment variables" do
      expect(ENV["RAILS_ENV"]).to be_present
      expect(ENV["RAILS_MASTER_KEY"]).to be_present
      expect(ENV["SECRET_KEY_BASE"]).to be_present
    end
  end
end 