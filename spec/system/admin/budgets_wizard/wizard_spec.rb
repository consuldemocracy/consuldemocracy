require "rails_helper"

describe "Budgets creation wizard", :admin do
  scenario "Creation of a single-heading budget by steps" do
    visit admin_budgets_path
    click_button "Create new budget"
    click_link "Create single heading budget"

    fill_in "Name", with: "Single heading budget"
    click_button "Continue to groups"

    expect(page).to have_content "New participatory budget created successfully!"
  end

  scenario "Creation of a multiple-headings budget by steps" do
    visit admin_budgets_path
    click_button "Create new budget"
    click_link "Create multiple headings budget"

    fill_in "Name", with: "Multiple headings budget"
    click_button "Continue to groups"

    expect(page).to have_content "New participatory budget created successfully!"
    expect(page).to have_content "There are no groups."
  end
end
