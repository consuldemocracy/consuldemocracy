require "rails_helper"

describe Admin::Poll::OfficersController do
  describe "POST /admin/officers" do
    it "does not create two records with two simultaneous requests", :race_condition, :admin do
      user = create(:user)
      path = admin_officers_path

      2.times.map do
        Thread.new { post path, params: { user_id: user.id } }
      end.each(&:join)

      expect(Poll::Officer.where(user: user).count).to be 1
    end
  end
end
