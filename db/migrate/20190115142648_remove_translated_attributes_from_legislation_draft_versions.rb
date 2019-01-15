class RemoveTranslatedAttributesFromLegislationDraftVersions < ActiveRecord::Migration
  def change
    remove_columns :legislation_draft_versions, :title, :changelog, :body,
      :body_html, :toc_html
  end
end
