class AddTocHtmlToDraftVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_draft_versions, :toc_html, :text
  end
end
