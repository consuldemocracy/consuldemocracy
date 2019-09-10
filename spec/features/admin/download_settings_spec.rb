require "rails_helper"

describe "Admin download settings" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Edit download settings debates" do
    visit admin_edit_download_settings_path(resource: "debates")

    expect(page).to have_content("Debates")
  end

  scenario "Update download settings debates" do
    visit admin_edit_download_settings_path(resource: "debates")

    find(:css, "#downloadable_[value='id']").set(true)
    find(:css, "#downloadable_[value='title']").set(true)

    click_button "Save changes"

    expect(DownloadSetting.find_by(name_model: "Debate",
                                   name_field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Debate",
                                   name_field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Debate",
                                   name_field: "description").downloadable).to eq false
  end

  context "Download debates" do

    before do
      create(:debate)
    end

    scenario "admin csv" do
      visit admin_debates_path

      click_button "Download"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="debates.csv"$/)
      expect(content_type).to match("text/csv")
    end

    scenario "public csv" do
      visit debates_path

      click_link "Download debates"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="debates.csv"$/)
      expect(content_type).to match("text/csv")
    end
  end

  scenario "Edit download settings proposals" do
    visit admin_edit_download_settings_path(resource: "proposals")

    expect(page).to have_content("Proposals")
  end

  scenario "Update download settings proposals" do
    visit admin_edit_download_settings_path(resource: "proposals")

    find(:css, "#downloadable_[value='id']").set(true)
    find(:css, "#downloadable_[value='title']").set(true)

    click_button "Save changes"

    expect(DownloadSetting.find_by(name_model: "Proposal",
                                   name_field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Proposal",
                                   name_field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Proposal",
                                   name_field: "description").downloadable).to eq false
  end

  context "Download proposals" do

    before do
      create(:proposal)
    end

    scenario "admin csv" do

      visit admin_proposals_path

      click_button "Download"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="proposals.csv"$/)
      expect(content_type).to match("text/csv")
    end

    scenario "public csv" do
      visit proposals_path

      click_link "Download proposals"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="proposals.csv"$/)
      expect(content_type).to match("text/csv")
    end
  end

  scenario "Edit download settings comments" do
    visit admin_edit_download_settings_path(resource: "comments")

    expect(page).to have_content("Comments")
  end

  scenario "Update download settings comments" do

    visit admin_edit_download_settings_path(resource: "comments")

    find(:css, "#downloadable_[value='id']").set(true)
    find(:css, "#downloadable_[value='body']").set(true)

    click_button "Save changes"

    expect(DownloadSetting.find_by(name_model: "Comment",
                                   name_field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Comment",
                                   name_field: "body").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Comment",
                                   name_field: "subject").downloadable).to eq false
  end

  scenario "Download comments" do
    create(:comment)

    visit admin_comments_path

    click_button "Download"

    header = page.response_headers["Content-Disposition"]
    content_type = page.response_headers["Content-Type"]
    expect(header).to match(/^attachment/)
    expect(header).to match(/filename="comments.csv"$/)
    expect(content_type).to match("text/csv")
  end

  scenario "Edit download settings legislation process" do
    visit admin_edit_download_settings_path(resource: "legislation_processes")

    expect(page).to have_content("Legislation process")

  end

  scenario "Update download settings legislation process" do

    visit admin_edit_download_settings_path(resource: "legislation_processes")

    find(:css, "#downloadable_[value='id']").set(true)
    find(:css, "#downloadable_[value='title']").set(true)

    click_button "Save changes"

    expect(DownloadSetting.find_by(name_model: "Legislation::Process",
                                   name_field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Legislation::Process",
                                   name_field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Legislation::Process",
                                   name_field: "description").downloadable).to eq false
  end

  context "Download legislation process" do

    before do
      create(:legislation_process, :open)
      create(:legislation_process, :published)
    end

    scenario "admin csv" do

      visit admin_legislation_processes_path

      click_button "Download"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="legislation_processes.csv"$/)
      expect(content_type).to match("text/csv")
    end

    scenario "public csv" do
      visit legislation_processes_path

      click_link "Download legislation processes"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="legislation_processes.csv"$/)
      expect(content_type).to match("text/csv")
    end
  end

  scenario "Edit download settings budget investment results" do
    visit admin_edit_download_settings_path(resource: "budget_investments")

    expect(page).to have_content("Participatory budgeting")

  end

  scenario "Update download settings budget investment results" do

    visit admin_edit_download_settings_path(resource: "budget_investments")

    find(:css, "#downloadable_[value='id']").set(true)
    find(:css, "#downloadable_[value='title']").set(true)

    click_button "Save changes"

    expect(DownloadSetting.find_by(name_model: "Budget::Investment",
                                   name_field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Budget::Investment",
                                   name_field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Budget::Investment",
                                   name_field: "description").downloadable).to eq false
  end

  scenario "Edit download settings budget investment milestones" do
    visit admin_edit_download_settings_path(resource: "budget_investments", config: 1)

    expect(page).to have_content("Participatory budgeting - Milestones")

  end

  scenario "Update download settings budget investment milestones" do

    visit admin_edit_download_settings_path(resource: "budget_investments", config: 1)

    find(:css, "#downloadable_[value='id']").set(true)
    find(:css, "#downloadable_[value='title']").set(true)

    click_button "Save changes"

    expect(DownloadSetting.find_by(name_model: "Budget::Investment",
                                   name_field: "id",
                                   config: 1).downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Budget::Investment",
                                   name_field: "title",
                                   config: 1).downloadable).to eq true
    expect(DownloadSetting.find_by(name_model: "Budget::Investment",
                                   name_field: "description",
                                   config: 1).downloadable).to eq false
  end

  context "Download budgets" do
    let(:budget_finished)  { create(:budget, phase: "finished") }
    let(:group)   { create(:budget_group, budget: budget_finished) }
    let(:heading) { create(:budget_heading, group: group, price: 1000) }

    let(:investment1) { create(:budget_investment,
                               :selected,
                               heading: heading,
                               price: 200,
                               ballot_lines_count: 900) }
    let(:investment2) { create(:budget_investment,
                               :selected,
                               heading: heading,
                               price: 300,
                               ballot_lines_count: 800) }
    let(:investment3) { create(:budget_investment,
                               :incompatible,
                               heading: heading,
                               price: 500,
                               ballot_lines_count: 700) }
    let(:investment4) { create(:budget_investment,
                               :selected,
                               heading: heading,
                               price: 600,
                               ballot_lines_count: 600) }
    let(:budget) { create :budget }

    before do
      Budget::Result.new(budget_finished, heading).calculate_winners
    end

    scenario "admin results csv" do
      visit admin_budget_budget_investments_path(budget_id: budget.id)

      click_button "Download"

      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="budget_investments.csv"$/)
      expect(content_type).to match("text/csv")
    end

    xscenario "public csv results" do
      visit budget_results_path(budget_id: budget_finished.id)
      save_page
      click_link "Download projects"
      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="budget_investment_results.csv"$/)
      expect(content_type).to match("text/csv")
    end

    scenario "public csv milestones" do
      visit budget_executions_path(budget_id: budget_finished.id)
      save_page
      click_link "Download projects"
      header = page.response_headers["Content-Disposition"]
      content_type = page.response_headers["Content-Type"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="budget_investment_milestones.csv"$/)
      expect(content_type).to match("text/csv")
    end
  end

end
