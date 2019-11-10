require "rails_helper"

describe "Admin comments" do
  before do
    admin = create(:administrator)
    login_as(admin.user)
  end
end
