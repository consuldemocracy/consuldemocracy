class AddBodyHtmlToDraftVersions < ActiveRecord::Migration
  def change
    add_column :legislation_draft_versions, :body_html, :text
  end
end
