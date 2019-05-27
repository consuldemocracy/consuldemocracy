class AddRetiredToProposals < ActiveRecord::Migration[4.2]
  def change
    add_column :proposals, :retired_at, :datetime, default: nil
  end
end
