require "rails_helper"

feature "Budget Groups" do

  let(:budget) { create(:budget) }
  let(:group)  { create(:budget_group, budget: budget) }

  context "Show" do
    scenario "Headings are sorted by name" do
      last_heading = create(:budget_heading, group: group, name: "BBB")
      first_heading = create(:budget_heading, group: group, name: "AAA")

      visit budget_group_path(budget, group)

      expect(first_heading.name).to appear_before(last_heading.name)
    end
  end

end
