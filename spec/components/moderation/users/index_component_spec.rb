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
        expect(table).not_to have_content "Hidden"
      end
    end

    context "for hidden users" do
      it "shows 'blocked' when the user has been blocked" do
        user = create(:user, :hidden)
        Activity.log(nil, :block, user)

        render_inline component

        page.find("table") do |table|
          expect(table).to have_content "Blocked"
          expect(table).not_to have_content "Hidden"
          expect(table).not_to have_button
        end
      end

      it "shows 'hidden' when the user has been hidden" do
        user = create(:user, :hidden)
        Activity.log(nil, :hide, user)

        render_inline component

        page.find("table") do |table|
          expect(table).to have_content "Hidden"
          expect(table).not_to have_content "Blocked"
          expect(table).not_to have_button
        end
      end

      it "shows 'blocked' when there are no activities to hide the user" do
        create(:user, :hidden)

        render_inline component

        page.find("table") do |table|
          expect(table).to have_content "Blocked"
        end
      end

      it "is not affected by activities for other users" do
        blocked = create(:user, :hidden, username: "Very bad user")
        hidden = create(:user, :hidden, username: "Slightly bad user")

        Activity.log(nil, :block, blocked)
        Activity.log(nil, :hide, hidden)

        render_inline component

        page.find("tr", text: "Very bad user") do |row|
          expect(row).to have_content "Blocked"
        end

        page.find("tr", text: "Slightly bad user") do |row|
          expect(row).to have_content "Hidden"
        end
      end

      it "doesn't consider activities other than block or hide" do
        user = create(:user, :hidden)
        Activity.log(nil, :block, user)
        Activity.log(nil, :restore, user)

        render_inline component

        page.find("table") do |table|
          expect(table).to have_content "Blocked"
        end
      end

      it "shows actions after the user has been restored" do
        user = create(:user, :hidden)
        Activity.log(nil, :block, user)
        user.restore

        render_inline component

        page.find("table") do |table|
          expect(table).to have_button "Hide"
          expect(table).to have_button "Block"
          expect(table).not_to have_content "Blocked"
          expect(table).not_to have_content "Hidden"
        end
      end
    end
  end
end
