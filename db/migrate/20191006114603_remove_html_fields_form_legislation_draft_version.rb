class RemoveHtmlFieldsFormLegislationDraftVersion < ActiveRecord::Migration[5.0]
  def change
    remove_column :legislation_draft_versions, :body_html
    remove_column :legislation_draft_version_translations, :body_html
    remove_column :legislation_draft_versions, :toc_html
    remove_column :legislation_draft_version_translations, :toc_html
  end
end
