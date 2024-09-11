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

        refresh

        within "#comments" do
          expect(page).to have_content "I am your Admin!"
          expect(page).to have_content "Administrator user description"
          expect(page).to have_css "div.is-admin"
          expect(page).to have_css "img.admin-avatar"
        end
      end
    end
  end
end
