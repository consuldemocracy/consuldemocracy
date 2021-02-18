require "rails_helper"

describe "Signature sheets", :admin do
  context "Index" do
    scenario "Lists all signature_sheets" do
      3.times { create(:signature_sheet) }

      visit admin_signature_sheets_path

      expect(page).to have_css(".signature_sheet", count: 3)

      SignatureSheet.find_each do |signature_sheet|
        expect(page).to have_content signature_sheet.name
      end
    end

    scenario "Orders signature_sheets by created_at DESC" do
      signature_sheet1 = create(:signature_sheet)
      signature_sheet2 = create(:signature_sheet)
      signature_sheet3 = create(:signature_sheet)

      visit admin_signature_sheets_path

      expect(signature_sheet3.name).to appear_before(signature_sheet2.name)
      expect(signature_sheet2.name).to appear_before(signature_sheet1.name)
    end
  end

  context "Create" do
    scenario "Proposal" do
      proposal = create(:proposal)
      visit new_admin_signature_sheet_path

      fill_in "signature_sheet_title", with: "definitive signature sheet"
      select "Citizen proposal", from: "signature_sheet_signable_type"
      fill_in "signature_sheet_signable_id", with: proposal.id
      fill_in "signature_sheet_required_fields_to_verify", with: "12345678Z; 1234567L; 99999999Z"
      click_button "Create signature sheet"

      expect(page).to have_content "Signature sheet created successfully"
      expect(page).to have_content "There is 1 valid signature"
      expect(page).to have_content "There is 1 vote created from the verified signatures"
      expect(page).to have_content "There are 2 invalid signatures"

      visit proposal_path(proposal)

      expect(page).to have_content "1 support"
    end

    scenario "Budget Investment" do
      investment = create(:budget_investment)
      budget = investment.budget
      budget.update!(phase: "selecting")

      visit new_admin_signature_sheet_path

      fill_in "signature_sheet_title", with: "definitive signature sheet"
      select "Investment", from: "signature_sheet_signable_type"
      fill_in "signature_sheet_signable_id", with: investment.id
      fill_in "signature_sheet_required_fields_to_verify", with: "12345678Z; 1234567L; 99999999Z"
      click_button "Create signature sheet"

      expect(page).to have_content "Signature sheet created successfully"
      expect(page).to have_content "There is 1 valid signature"
      expect(page).to have_content "There is 1 vote created from the verified signatures"
      expect(page).to have_content "There are 2 invalid signatures"

      visit budget_investment_path(budget, investment)

      expect(page).to have_content "1 support"
    end
  end

  context "Create throught all required_fields_to_verify of custom census api", :remote_census do
    before do
      mock_valid_remote_census_response
      mock_invalid_signature_sheet_remote_census_response
    end

    scenario "Proposal" do
      proposal = create(:proposal)
      visit new_admin_signature_sheet_path

      select "Citizen proposal", from: "signature_sheet_signable_type"
      fill_in "signature_sheet_signable_id", with: proposal.id
      fill_in "signature_sheet_required_fields_to_verify", with: "12345678Z, 31/12/1980, 28013; 99999999Z, 31/12/1980, 28013"
      click_button "Create signature sheet"

      expect(page).to have_content "Signature sheet created successfully"

      visit proposal_path(proposal)

      expect(page).to have_content "1 support"
    end

    scenario "Budget Investment" do
      investment = create(:budget_investment)
      budget = investment.budget
      budget.update!(phase: "selecting")

      visit new_admin_signature_sheet_path

      select "Investment", from: "signature_sheet_signable_type"
      fill_in "signature_sheet_signable_id", with: investment.id
      fill_in "signature_sheet_required_fields_to_verify", with: "12345678Z, 31/12/1980, 28013; 99999999Z, 31/12/1980, 28013"
      click_button "Create signature sheet"

      expect(page).to have_content "Signature sheet created successfully"

      visit budget_investment_path(budget, investment)

      expect(page).to have_content "1 support"
    end
  end

  scenario "Errors on create" do
    visit new_admin_signature_sheet_path

    click_button "Create signature sheet"

    expect(page).to have_content error_message
  end

  scenario "Show" do
    proposal = create(:proposal)
    user = Administrator.first.user
    signature_sheet = create(:signature_sheet,
                             :with_title,
                             signable: proposal,
                             required_fields_to_verify: "12345678Z; 123A; 123B",
                             author: user)
    signature_sheet.verify_signatures

    visit admin_signature_sheet_path(signature_sheet)

    expect(page).to have_content "Citizen proposal #{proposal.id}: #{signature_sheet.title}"
    expect(page).to have_content "12345678Z; 123A; 123B"
    expect(page).to have_content signature_sheet.created_at.strftime("%B %d, %Y %H:%M")
    expect(page).to have_content user.name

    within("#signature_count") do
      expect(page).to have_content 3
    end

    within("#verified_signatures") do
      expect(page).to have_content 1
    end

    within("#unverified_signatures") do
      expect(page).to have_content 2
    end
  end
end
