require "rails_helper"

feature "Budget Groups" do

  let(:budget) { create(:budget, slug: "budget_slug") }
  let!(:group)  { create(:budget_group, slug: "group_slug", budget: budget) }

  context "Load" do

    scenario "finds group using budget slug and group slug" do
      visit budget_group_path("budget_slug", "group_slug")
      expect(page).to have_content "Select an option"
    end

    scenario "finds group using budget id and group id" do
      visit budget_group_path(budget, group)
      expect(page).to have_content "Select an option"
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_group_path("wrong_budget", group)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_group_path(0, group)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if group slug is not found" do
      expect do
        visit budget_group_path(budget, "wrong_group")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if group id is not found" do
      expect do
        visit budget_group_path(budget, 0)
      end.to raise_error ActiveRecord::RecordNotFound
    end

  end

end
