require "rails_helper"

describe Admin::ManagersController do
  describe "POST /admin/managers" do
    it "does not create two records with two simultaneous requests", :race_condition, :admin do
      user = create(:user)
      path = admin_managers_path

      2.times.map do
        Thread.new { post path, params: { user_id: user.id } }
      end.each(&:join)

      expect(Manager.where(user: user).count).to be 1
    end
  end
end
