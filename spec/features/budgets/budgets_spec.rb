require 'rails_helper'

feature 'Budgets' do

  scenario "Index" do
    budget1 = create(:budget)
    budget2 = create(:budget)
    budget3 = create(:budget)

    visit budgets_path

    expect(page).to have_css ".budget", count: 3
    expect(page).to have_content budget1.name
    expect(page).to have_content budget2.name
    expect(page).to have_content budget3.name
  end

end
