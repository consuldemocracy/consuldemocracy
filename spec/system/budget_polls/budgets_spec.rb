require "rails_helper"

describe "Admin Budgets", :admin do
  context "Index" do
    scenario "Create poll if the budget does not have a poll associated" do
      budget = create(:budget)
      balloting_phase = budget.phases.balloting

      visit admin_budget_path(budget)

      accept_confirm { click_button "Create booths" }

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content(budget.name)
      expect(page).to have_content(balloting_phase.starts_at.to_date)
      expect(page).to have_content(balloting_phase.ends_at.to_date)
    end

    scenario "Create poll in current locale if the budget does not have a poll associated" do
      budget = create(:budget,
                      name_en: "Budget for climate change",
                      name_es: "Presupuesto por el cambio climático")

      visit admin_budget_path(budget)
      select "Español", from: "Language:"

      accept_confirm { click_button "Crear urnas" }

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content "Presupuesto por el cambio climático"
    end
  end

  context "Show" do
    scenario "Do not show questions section if the budget have a poll associated" do
      poll = create(:poll, :for_budget)

      visit admin_poll_path(poll)

      within "#poll-resources" do
        expect(page).not_to have_content("Questions")
        expect(page).to have_content("Booths")
        expect(page).to have_content("Officers")
        expect(page).to have_content("Recounting")
        expect(page).to have_content("Results")
      end
    end
  end
end
