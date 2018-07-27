class AddPublishedAtToProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :published_at, :datetime, null: true
  end
end
