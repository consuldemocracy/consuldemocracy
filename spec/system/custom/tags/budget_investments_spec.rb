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

  scenario "Create with custom tags" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"

    fill_in "budget_investment_tag_list", with: "#{tag_medio_ambiente.name}, #{tag_economia.name}"

    click_button "Create Investment"

    expect(page).to have_content "Investment created successfully."
    expect(page).to have_content tag_economia.name
    expect(page).to have_content tag_medio_ambiente.name
  end

  scenario "Category with category tags" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "If I had a gym near my place I could go do Zumba"

    find(".js-add-tag-link", text: tag_economia.name).click
    click_button "Create Investment"

    expect(page).to have_content "Investment created successfully."
    expect(page).to have_content "Build a skyscraper"

    within ".tags" do
      expect(page).to have_content tag_economia.name
      expect(page).not_to have_content tag_medio_ambiente.name
    end
  end

  scenario "Turbolinks sanity check from budget's show" do
    create(:tag, name: "Education", kind: "category")
    create(:tag, name: "Health",    kind: "category")

    login_as(author)
    visit budget_path(budget)
    click_link "Create a budget investment"

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "If I had a gym near my place I could go do Zumba"

    find(".js-add-tag-link", text: "Education").click
    click_button "Create Investment"

    expect(page).to have_content "Investment created successfully."
    expect(page).to have_content "Build a skyscraper"

    within ".tags" do
      expect(page).to have_content "Education"
      expect(page).not_to have_content "Health"
    end
  end

  scenario "Turbolinks sanity check from budget heading's show" do
    create(:tag, name: "Education", kind: "category")
    create(:tag, name: "Health",    kind: "category")

    login_as(author)
    visit budget_investments_path(budget, heading_id: heading.id)
    click_link "Create a budget investment"

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "If I had a gym near my place I could go do Zumba"

    find(".js-add-tag-link", text: "Education").click
    click_button "Create Investment"

    expect(page).to have_content "Investment created successfully."
    expect(page).to have_content "Build a skyscraper"

    within ".tags" do
      expect(page).to have_content "Education"
      expect(page).not_to have_content "Health"
    end
  end

  scenario "Create with too many tags" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"

    fill_in "budget_investment_tag_list", with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button "Create Investment"

    expect(page).to have_content error_message
    expect(page).to have_content "tags must be less than or equal to 6"
  end

  scenario "Create with dangerous strings" do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)

    fill_in_new_investment_title with: "Build a skyscraper"
    fill_in_ckeditor "Description", with: "I want to live in a high tower over the clouds"

    fill_in "budget_investment_tag_list", with: "user_id=1, &a=3, <script>alert('hey');</script>"

    click_button "Create Investment"

    expect(page).to have_content "Investment created successfully."
    expect(page).to have_content "user_id1"
    expect(page).to have_content "a3"
    expect(page).to have_content "scriptalert('hey');script"
    expect(page.html).not_to include "user_id=1, &a=3, <script>alert('hey');</script>"
  end

  context "Tag cloud" do
    let(:new_tag)      { "New Tag" }
    let(:newer_tag)    { "Newer" }
    let!(:investment1) { create(:budget_investment, heading: heading, tag_list: new_tag) }
    let!(:investment2) { create(:budget_investment, heading: heading, tag_list: new_tag) }
    let!(:investment3) { create(:budget_investment, heading: heading, tag_list: newer_tag) }
    let(:phase) { Budget::Phase::PHASE_KINDS.sample }

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

      if budget.informing?
        visit budget_investments_path(budget, heading: heading.id)
      else
        visit budget_path(budget)
        click_link "See all investments"
      end

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

      if budget.informing?
        visit budget_investments_path(budget, heading: heading.id)
      else
        visit budget_path(budget)
        click_link "See all investments"
      end

      within "#categories" do
        click_link tag_medio_ambiente.name
      end

      expect(page).to have_css ".budget-investment", count: 2
      expect(page).to have_content investment1.title
      expect(page).to have_content investment2.title
      expect(page).not_to have_content investment3.title
    end
  end
end
