class AddBodyHtmlToDraftVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_draft_versions, :body_html, :text
  end
end
