require "rails_helper"

describe Moderation::Users::IndexComponent, controller: Moderation::UsersController do
  describe "actions or status" do
    let(:component) { Moderation::Users::IndexComponent.new(User.with_hidden.page(1)) }

    it "shows actions to block or hide users" do
      create(:user)

      render_inline component

      page.find("table") do |table|
        expect(table).to have_button "Hide"
        expect(table).to have_button "Block"
        expect(table).not_to have_content "Blocked"
      end
    end

    it "shows 'blocked' for hidden users" do
      create(:user, :hidden)

      render_inline component

      page.find("table") do |table|
        expect(table).to have_content "Blocked"
        expect(table).not_to have_button
      end
    end
  end
end
