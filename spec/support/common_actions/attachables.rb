module Attachables
  def imageable_attach_new_file(path, success: true)
    click_link "Add image"
    within "#nested-image" do
      attach_file "Choose image", path
      within ".image-fields" do
        if success
          expect(page).to have_css(".loading-bar.complete")
        else
          expect(page).to have_css(".loading-bar.errors")
        end
      end
    end
  end

  def documentable_attach_new_file(path, success: true)
    click_link "Add new document"
    within "#nested-documents" do
      attach_file "Choose document", path
      within ".document-fields" do
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
