class AddCountFeaturedProposalToSettings < ActiveRecord::Migration
  def up
    execute "INSERT INTO settings (key, value) VALUES ('count_featured_proposals', 3);"
  end

  def down
    execute "DELETE FROM settings where key = 'count_featured_proposals'"
  end
end
