class RemoveDeprecatedTranslatableFieldsFromLegislationDraftVersions < ActiveRecord::Migration[4.2]
  def change
    remove_column :legislation_draft_versions, :title, :string
    remove_column :legislation_draft_versions, :changelog, :text
    remove_column :legislation_draft_versions, :body, :text
    remove_column :legislation_draft_versions, :body_html, :text
    remove_column :legislation_draft_versions, :toc_html, :text
  end
end
