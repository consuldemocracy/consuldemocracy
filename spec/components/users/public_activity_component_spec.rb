require "rails_helper"

describe Users::PublicActivityComponent, controller: UsersController do
  include Rails.application.routes.url_helpers

  around do |example|
    with_request_url(user_path(user)) { example.run }
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

        with_request_url user_path(user, filter: "follows") do
          render_inline component

          expect(page).to have_selector "li.is-active", text: "1 Following"
        end
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

  describe "comments" do
    let(:user) { create(:user) }
    let(:component) { Users::PublicActivityComponent.new(user) }

    it "doesn't show comments for disabled features" do
      Setting["process.budgets"] = false
      Setting["process.debates"] = false
      Setting["process.legislation"] = false
      Setting["process.polls"] = false
      Setting["process.proposals"] = false

      create(:budget_investment_comment, user: user)
      create(:debate_comment, user: user)
      create(:legislation_annotation_comment, user: user)
      create(:legislation_question_comment, user: user)
      create(:legislation_proposal_comment, user: user)
      create(:poll_comment, user: user)
      create(:proposal_comment, user: user)

      render_inline component

      expect(page).not_to have_content "Comments"
    end
  end
end
