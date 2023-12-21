require "rails_helper"

describe "Commenting Budget::Investments" do
  let(:investment) { create(:budget_investment) }

  describe "Administrators" do
    context "comment as administrator" do
      scenario "display administrator description on admin views" do
        admin = create(:administrator, description: "user description")

        login_as(admin.user)

        visit admin_budget_budget_investment_path(investment.budget, investment)

        fill_in "Leave your comment", with: "I am your Admin!"
        check "comment-as-administrator-budget_investment_#{investment.id}"
        click_button "Publish comment"

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
        end

        visit admin_budget_budget_investment_path(investment.budget, investment)

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
          expect(page).to have_content "Administrator user description"
          expect(page).to have_css "div.is-admin"
          expect(page).to have_css "img.admin-avatar"
        end
      end

      scenario "display administrator id on public views" do
        admin = create(:administrator, description: "user description")

        login_as(admin.user)
        visit admin_budget_budget_investment_path(investment.budget, investment)

        fill_in "Leave your comment", with: "I am your Admin!"
        check "comment-as-administrator-budget_investment_#{investment.id}"
        click_button "Publish comment"

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
          expect(page).to have_content "Administrator ##{admin.id}"
          expect(page).to have_css "div.is-admin"
          expect(page).to have_css "img.admin-avatar"
        end
      end

      scenario "public users not see admin description" do
        manuela = create(:user, username: "Manuela")
        admin   = create(:administrator, user: manuela)
        comment = create(:comment,
                         commentable: investment,
                         user: manuela,
                         administrator_id: admin.id)

        visit budget_investment_path(investment.budget, investment)

        within "#comment_#{comment.id}" do
          expect(page).to have_content comment.body
          expect(page).to have_content "Administrator ##{admin.id}"
          expect(page).to have_css "img.admin-avatar"
          expect(page).to have_css "div.is-admin"
        end
      end
    end
  end
end
