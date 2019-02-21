class RenameDeprecatedTranslatableLegislationDraftVersionFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :legislation_draft_versions, :title, :deprecated_title
    rename_column :legislation_draft_versions, :changelog, :deprecated_changelog
    rename_column :legislation_draft_versions, :body, :deprecated_body
    rename_column :legislation_draft_versions, :body_html, :deprecated_body_html
    rename_column :legislation_draft_versions, :toc_html, :deprecated_toc_html
  end
end
