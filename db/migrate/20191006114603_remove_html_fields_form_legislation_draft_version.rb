class RemoveHtmlFieldsFormLegislationDraftVersion < ActiveRecord::Migration[5.0]
  def change
    remove_column :legislation_draft_versions, :body_html, :text
    remove_column :legislation_draft_version_translations, :body_html, :text
    remove_column :legislation_draft_versions, :toc_html, :text
    remove_column :legislation_draft_version_translations, :toc_html, :text
  end
end
