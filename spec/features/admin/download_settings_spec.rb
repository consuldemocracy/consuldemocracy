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

    expect(DownloadSetting.find_by(model: "Debate",
                                   field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Debate",
                                   field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Debate",
                                   field: "description").downloadable).to eq false
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

    expect(DownloadSetting.find_by(model: "Proposal",
                                   field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Proposal",
                                   field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Proposal",
                                   field: "description").downloadable).to eq false
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

    expect(DownloadSetting.find_by(model: "Comment",
                                   field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Comment",
                                   field: "body").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Comment",
                                   field: "subject").downloadable).to eq false
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

    expect(DownloadSetting.find_by(model: "Legislation::Process",
                                   field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Legislation::Process",
                                   field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Legislation::Process",
                                   field: "description").downloadable).to eq false
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

    expect(DownloadSetting.find_by(model: "Budget::Investment",
                                   field: "id").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Budget::Investment",
                                   field: "title").downloadable).to eq true
    expect(DownloadSetting.find_by(model: "Budget::Investment",
                                   field: "description").downloadable).to eq false
  end

  context "Download budgets" do
    let(:budget_finished) { create(:budget, :finished) }
    let(:heading) { create(:budget_heading, budget: budget_finished, price: 1000) }

    let(:investment1) do
      create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900)
    end

    let(:investment2) do
      create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800)
    end

    let(:investment3) do
      create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700)
    end

    let(:investment4) do
      create(:budget_investment, :selected, heading: heading, price: 600, ballot_lines_count: 600)
    end

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
  end
end
