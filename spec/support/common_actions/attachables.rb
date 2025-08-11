module Attachables
  def imageable_attach_new_file(path, success: true)
    attach_new_file("Add image", "nested-image", "image", "Choose image", path, success)
  end

  def documentable_attach_new_file(path, success: true)
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
    when :budget then fill_in_budget
    when :budget_investment then fill_in_budget_investment
    when :dashboard_action then fill_in_dashboard_action
    when :proposal then fill_in_proposal
    end
  end

  def attachable_path_for(factory, attachable)
    case factory
    when :budget then new_admin_budgets_wizard_budget_path
    when :budget_investment
      [
        new_budget_investment_path(budget_id: attachable.budget_id),
        new_management_budget_investment_path(budget_id: attachable.budget_id)
      ].sample
    when :dashboard_action then new_admin_dashboard_action_path
    when :future_poll_question_option then new_admin_option_image_path(option_id: attachable.id)
    when :proposal then [new_proposal_path, edit_proposal_path(attachable)].sample
    end
  end

  def submit_button_text_for(factory, path)
    case factory
    when :budget then "Continue to groups"
    when :budget_investment then "Create Investment"
    when :dashboard_action then "Save"
    when :future_poll_question_option then "Save image"
    when :proposal
      if edit_path?(path)
        "Save changes"
      else
        "Create proposal"
      end
    end
  end

  def notice_text_for(factory, path)
    case factory
    when :budget then "New participatory budget created successfully!"
    when :budget_investment then "Budget Investment created successfully."
    when :dashboard_action then "Action created successfully"
    when :future_poll_question_option then "Image uploaded successfully"
    when :proposal
      if edit_path?(path)
        "Proposal updated successfully"
      else
        "Proposal created successfully"
      end
    end
  end
end
