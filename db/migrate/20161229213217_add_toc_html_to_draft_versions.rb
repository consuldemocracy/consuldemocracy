class AddTocHtmlToDraftVersions < ActiveRecord::Migration
  def change
    add_column :legislation_draft_versions, :toc_html, :text
  end
end
