require "rails_helper"

describe "Admin budget investments", :admin do
  let(:budget) { create(:budget) }
  let(:administrator) do
    create(:administrator, user: create(:user, username: "Ana", email: "ana@admins.org"))
  end
  context "Columns chooser" do
    scenario "Set cookie with default columns value if undefined", :consul do
      visit admin_budget_budget_investments_path(budget)

      cookie_value = cookie_by_name("investments-columns")[:value]

      expect(cookie_value).to eq("id,title,created_at,supports,votes,admin,geozone,feasibility," \
                                 "price,valuation_finished,visible_to_valuators,selected,incompatible")
    end

    scenario "Cookie will be updated after change columns selection", :consul do
      visit admin_budget_budget_investments_path(budget)

      click_button "Columns"

      expect(page).to have_css "button[aria-expanded=true]", exact_text: "Columns"

      within("#js-columns-selector-wrapper") do
        uncheck "Title"
        uncheck "Price"
        uncheck "Valuation Group / Valuator"
        uncheck "Created at"
        check "Author"
      end

      cookie_value = cookie_by_name("investments-columns")[:value]

      expect(cookie_value).to eq("id,supports,votes,admin,geozone,feasibility," \
                                 "valuation_finished,visible_to_valuators,selected,incompatible,author")

      refresh

      expect(page).to have_css "button[aria-expanded=false]", exact_text: "Columns"

      cookie_value = cookie_by_name("investments-columns")[:value]

      expect(cookie_value).to eq("id,created_at,supports,votes,admin,geozone,feasibility," \
                                 "valuation_finished,visible_to_valuators,selected,incompatible,author")
    end
  end
end
