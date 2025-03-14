require "rails_helper"

describe "Tags" do
  let(:author)  { create(:user, :level_two, username: "Isabel") }
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:group)   { create(:budget_group, name: "Health", budget: budget) }
  let!(:heading) do
    create(:budget_heading, name: "More hospitals",
                            group: group, latitude: "40.416775", longitude: "-3.703790")
  end
  let!(:tag_medio_ambiente) { create(:tag, :category, name: "Medio Ambiente") }
  let!(:tag_economia) { create(:tag, :category, name: "Economía") }
  let(:admin) { create(:administrator).user }

  scenario "Index" do
    earth = create(:budget_investment, heading: heading, tag_list: tag_medio_ambiente.name)
    money = create(:budget_investment, heading: heading, tag_list: tag_economia.name)

    visit budget_investments_path(budget, heading_id: heading.id)

    within "#budget_investment_#{earth.id}" do
      expect(page).to have_content(tag_medio_ambiente.name)
    end

    within "#budget_investment_#{money.id}" do
      expect(page).to have_content(tag_economia.name)
    end
  end

  scenario "Index shows 3 tags with no plus link" do
    tag_list = ["Medio Ambiente", "Corrupción", "Fiestas populares"]
    create(:budget_investment, heading: heading, tag_list: tag_list)

    visit budget_investments_path(budget, heading_id: heading.id)

    within(".budget-investment .tags") do
      tag_list.each do |tag|
        expect(page).to have_content tag
      end
      expect(page).not_to have_content "+"
    end
  end

  scenario "Index shows up to 5 tags per investment" do
    tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
    create(:budget_investment, heading: heading, tag_list: tag_list)

    visit budget_investments_path(budget, heading_id: heading.id)

    within(".budget-investment .tags") do
      expect(page).to have_content "1+"
    end
  end

  scenario "Show" do
    investment = create(:budget_investment,
                        heading: heading,
                        tag_list: "#{tag_medio_ambiente.name}, #{tag_economia.name}")

    visit budget_investment_path(budget, investment)

    expect(page).to have_content(tag_medio_ambiente.name)
    expect(page).to have_content(tag_economia.name)
  end

  scenario "Create with custom tags" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
    check   "budget_investment_terms_of_service"

    fill_in "budget_investment_tag_list", with: "#{tag_medio_ambiente.name}, #{tag_economia.name}"

    click_button "Create Investment"

    expect(page).to have_content "Budget Investment created successfully."
    expect(page).to have_content tag_economia.name
    expect(page).to have_content tag_medio_ambiente.name
  end

  scenario "Category with category tags" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "If I had a gym near my place I could go do Zumba"
    check "budget_investment_terms_of_service"

    find(".js-add-tag-link", text: tag_economia.name).click
    click_button "Create Investment"

    expect(page).to have_content "Budget Investment created successfully."
    expect(page).to have_content "Build a skyscraper"

    within ".tags" do
      expect(page).to have_content tag_economia.name
      expect(page).not_to have_content tag_medio_ambiente.name
    end
  end

  scenario "Create with too many tags" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
    check   "budget_investment_terms_of_service"

    fill_in "budget_investment_tag_list",
            with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button "Create Investment"

    expect(page).to have_content error_message
    expect(page).to have_content "tags must be less than or equal to 6"
  end

  scenario "Create with dangerous strings" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"
    check   "budget_investment_terms_of_service"

    fill_in "budget_investment_tag_list", with: "user_id=1, &a=3, <script>alert('hey');</script>"

    click_button "Create Investment"

    expect(page).to have_content "Budget Investment created successfully."
    expect(page).to have_content "user_id1"
    expect(page).to have_content "a3"
    expect(page).to have_content "scriptalert('hey');script"
    expect(page.html).not_to include "user_id=1, &a=3, <script>alert('hey');</script>"
  end

  context "Filter" do
    scenario "From index" do
      create(:budget_investment, heading: heading, tag_list: "Economy", title: "New bank")
      create(:budget_investment, heading: heading, tag_list: "Health", title: "New hospital")

      visit budget_investments_path(budget, heading_id: heading.id)

      within ".budget-investment", text: "New bank" do
        click_link "Economy"
      end

      within("#budget-investments") do
        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content "New bank"
      end
    end

    scenario "From show" do
      investment = create(:budget_investment, heading: heading, tag_list: "Economy", title: "New bank")
      create(:budget_investment, heading: heading, tag_list: "Health", title: "New hospital")

      visit budget_investment_path(budget, investment)

      click_link "Economy"

      within("#budget-investments") do
        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content "New bank"
      end
    end
  end

  context "Tag cloud" do
    let(:new_tag)      { "New Tag" }
    let(:newer_tag)    { "Newer" }
    let!(:investment1) { create(:budget_investment, heading: heading, tag_list: new_tag) }
    let!(:investment2) { create(:budget_investment, heading: heading, tag_list: new_tag) }
    let!(:investment3) { create(:budget_investment, heading: heading, tag_list: newer_tag) }
    let(:phase) { Budget::Phase::PHASE_KINDS.sample }

    scenario "Display user tags" do
      budget.update!(phase: phase)

      visit budget_investments_path(budget, heading_id: heading.id)

      within "#tag-cloud" do
        expect(page).to have_content(new_tag)
        expect(page).to have_content(newer_tag)
      end
    end

    scenario "Filter by user tags" do
      budget.update!(phase: phase)

      [investment1, investment2, investment3].each do |investment|
        investment.update(selected: true, feasibility: "feasible")
      end

      if budget.finished?
        [investment1, investment2, investment3].each do |investment|
          investment.update(selected: true, feasibility: "feasible", winner: true)
        end
      end

      visit budget_investments_path(budget, heading: heading.id)

      within "#tag-cloud" do
        click_link new_tag
      end

      expect(page).to have_css ".budget-investment", count: 2
      expect(page).to have_content investment1.title
      expect(page).to have_content investment2.title
      expect(page).not_to have_content investment3.title
    end
  end

  context "Categories" do
    let!(:investment1) { create(:budget_investment, heading: heading, tag_list: tag_medio_ambiente.name) }
    let!(:investment2) { create(:budget_investment, heading: heading, tag_list: tag_medio_ambiente.name) }
    let!(:investment3) { create(:budget_investment, heading: heading, tag_list: tag_economia.name) }
    let(:phase) { Budget::Phase::PHASE_KINDS.sample }

    scenario "Display category tags" do
      budget.update!(phase: phase)

      visit budget_investments_path(budget, heading_id: heading.id)

      within "#categories" do
        expect(page).to have_content(tag_medio_ambiente.name)
        expect(page).to have_content(tag_economia.name)
      end
    end

    scenario "Filter by category tags" do
      budget.update!(phase: phase)

      [investment1, investment2, investment3].each do |investment|
        investment.update(selected: true, feasibility: "feasible")
      end

      if budget.finished?
        [investment1, investment2, investment3].each do |investment|
          investment.update(selected: true, feasibility: "feasible", winner: true)
        end
      end

      visit budget_investments_path(budget, heading: heading.id)

      within "#categories" do
        click_link tag_medio_ambiente.name
      end

      expect(page).to have_css ".budget-investment", count: 2
      expect(page).to have_content investment1.title
      expect(page).to have_content investment2.title
      expect(page).not_to have_content investment3.title
    end
  end

  context "Valuation" do
    scenario "Users do not see valuator tags" do
      investment = create(:budget_investment, heading: heading, tag_list: "Park")
      investment.set_tag_list_on(:valuation, "Education")
      investment.save!

      visit budget_investment_path(budget, investment)

      expect(page).to     have_content "Park"
      expect(page).not_to have_content "Education"
    end

    scenario "Valuators do not see user tags", :admin do
      investment = create(:budget_investment, heading: heading, tag_list: "Park")
      investment.set_tag_list_on(:valuation_tags, "Education")
      investment.save!

      visit admin_budget_budget_investment_path(budget, investment)
      click_link "Edit classification"

      expect(page).to     have_content "Education"
      expect(page).not_to have_content "Park"
    end
  end
end
