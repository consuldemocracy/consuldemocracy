module Documents
  def documentable_redirected_to_resource_show_or_navigate_to
    find("a", text: "Not now, go to my proposal")
    click_on "Not now, go to my proposal"
  rescue
    nil
  end

  def documentable_attach_new_file(path, success = true)
    click_link "Add new document"

    document = all(".document").last
    attach_file "Choose document", path

    within document do
      if success
        expect(page).to have_css ".loading-bar.complete"
      else
        expect(page).to have_css ".loading-bar.errors"
      end
    end
  end

  def expect_document_has_title(index, title)
    document = all(".document")[index]

    within document do
      expect(find("input[name$='[title]']").value).to eq title
    end
  end

  def documentable_fill_new_valid_proposal
    fill_in_new_proposal_title with: "Proposal title #{rand(9999)}"
    fill_in "Proposal summary", with: "Proposal summary"
    check :proposal_terms_of_service
  end

  def documentable_fill_new_valid_dashboard_action
    fill_in :dashboard_action_title, with: "Dashboard title"
    fill_in_ckeditor "Description", with: "Dashboard description"
  end

  def documentable_fill_new_valid_budget_investment
    fill_in_new_investment_title with: "Budget investment title"
    fill_in_ckeditor "Description", with: "Budget investment description"
    check :budget_investment_terms_of_service
  end
end
