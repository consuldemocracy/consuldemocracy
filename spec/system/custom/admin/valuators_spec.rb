require "rails_helper"

describe "Admin valuators", :admin do
  let!(:valuator) { create(:valuator, description: "Very reliable") }

  context "Destroy" do
    scenario "Valuator not assigned to a budget" do
      visit admin_valuators_path

      accept_confirm("Are you sure? This action will delete \"#{valuator.name}\" and can't be undone.") do
        click_button "Delete"
      end

      within("#valuators") do
        expect(page).not_to have_content(valuator.name)
      end
    end

    scenario "Valuator assigned to a budget" do
      create(:budget, valuators: [valuator])

      visit admin_valuators_path

      accept_confirm("Are you sure? This action will delete \"#{valuator.name}\" and can't be undone.") do
        click_button "Delete"
      end

      within("#valuators") do
        expect(page).not_to have_content(valuator.name)
      end
    end
  end
end
