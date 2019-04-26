class AddPublishedAtToProposal < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :published_at, :datetime, null: true
  end
end
