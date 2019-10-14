class AddAssignmentsCounterCacheToValuators < ActiveRecord::Migration
  def change
    add_column :valuators, :spending_proposals_count, :integer, default: 0
  end
end
