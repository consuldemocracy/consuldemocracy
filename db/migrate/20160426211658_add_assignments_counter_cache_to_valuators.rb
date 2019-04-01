class AddAssignmentsCounterCacheToValuators < ActiveRecord::Migration[4.2]
  def change
    add_column :valuators, :spending_proposals_count, :integer, default: 0
  end
end
