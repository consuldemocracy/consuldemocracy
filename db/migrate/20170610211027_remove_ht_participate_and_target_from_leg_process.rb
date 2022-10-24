class RemoveHtParticipateAndTargetFromLegProcess < ActiveRecord::Migration[4.2]
  def change
    remove_column :legislation_processes, :how_to_participate, :text
    remove_column :legislation_processes, :target, :text
  end
end
