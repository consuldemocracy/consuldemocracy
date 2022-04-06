class AddGoalsToLocalTargets < ActiveRecord::Migration[5.2]
  def change
    add_reference :sdg_local_targets, :goal
  end
end
