class AddRetiredToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :retired_at, :datetime, default: nil
  end
end
