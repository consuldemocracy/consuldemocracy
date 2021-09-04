require "rails_helper"

describe Users::PublicActivityComponent, controller: UsersController do
  around do |example|
    with_request_url(Rails.application.routes.url_helpers.user_path(user)) { example.run }
  end

  describe "follows tab" do
    context "public interests is checked" do
      let(:user) { create(:user, public_interests: true) }
      let(:component) { Users::PublicActivityComponent.new(user) }

      it "is displayed for everyone" do
        create(:proposal, author: user, followers: [user])

        render_inline component

        expect(page).to have_content "1 Following"
      end

      it "is not displayed when the user isn't following any followables" do
        create(:proposal, author: user)

        render_inline component

        expect(page).not_to have_content "Following"
      end

      it "is the active tab when the follows filters is selected" do
        create(:proposal, author: user, followers: [user])
        controller.params["filter"] = "follows"

        render_inline component

        expect(page).to have_selector "li.is-active", text: "1 Following"
      end
    end

    context "public interests is not checked" do
      let(:user) { create(:user, public_interests: false) }
      let(:component) { Users::PublicActivityComponent.new(user) }

      it "is displayed for its owner" do
        create(:proposal, followers: [user])
        sign_in(user)

        render_inline component

        expect(page).to have_content "1 Following"
      end

      it "is not displayed for anonymous users" do
        create(:proposal, author: user, followers: [user])

        render_inline component

        expect(page).to have_content "1 Proposal"
        expect(page).not_to have_content "Following"
      end

      it "is not displayed for other users" do
        create(:proposal, author: user, followers: [user])
        sign_in(create(:user))

        render_inline component

        expect(page).to have_content "1 Proposal"
        expect(page).not_to have_content "Following"
      end

      it "is not displayed for administrators" do
        create(:proposal, author: user, followers: [user])
        sign_in(create(:administrator).user)

        render_inline component

        expect(page).to have_content "1 Proposal"
        expect(page).not_to have_content "Following"
      end
    end
  end
end
