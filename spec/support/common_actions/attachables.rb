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
end
