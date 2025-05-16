module Attachables
  def imageable_attach_new_file(path, success = true)
    attach_new_file("Add image", "nested-image", "image", "Choose image", path, success)
  end

  def documentable_attach_new_file(path, success = true)
    attach_new_file("Add new document", "nested-documents", "document", "Choose document", path, success)
  end

  def attach_new_file(link_text, wrapper_id, field_class, input_label, path, success)
    click_link link_text

    within "##{wrapper_id}" do
      attach_file input_label, path
      within ".#{field_class}-fields" do
        if success
          expect(page).to have_css ".loading-bar.complete"
        else
          expect(page).to have_css ".loading-bar.errors"
        end
      end
    end
  end

  def admin_section?(path)
    path.starts_with?("/admin/")
  end

  def management_section?(path)
    path.starts_with?("/management/")
  end

  def edit_path?(path)
    path.ends_with?("/edit")
  end

  def fill_in_required_fields(factory, path)
    return if edit_path?(path)

    case factory
    when :budget then fill_budget
    when :budget_investment then fill_budget_investment
    when :dashboard_action then fill_dashboard_action
    when :proposal then fill_proposal
    end
  end

  def fill_budget
    fill_in "Name", with: "Budget name"
  end

  def fill_dashboard_action
    fill_in :dashboard_action_title, with: "Dashboard title"
    fill_in_ckeditor "Description", with: "Dashboard description"
  end

  def fill_budget_investment
    fill_in_new_investment_title with: "Budget investment title"
    fill_in_ckeditor "Description", with: "Budget investment description"
    check :budget_investment_terms_of_service
  end

  def fill_proposal
    fill_in_new_proposal_title with: "Proposal title"
    fill_in "Proposal summary", with: "Proposal summary"
    check :proposal_terms_of_service
  end
end
