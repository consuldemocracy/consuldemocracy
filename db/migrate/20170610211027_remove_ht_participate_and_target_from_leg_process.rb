class RemoveHtParticipateAndTargetFromLegProcess < ActiveRecord::Migration
  def change
    remove_column :legislation_processes, :how_to_participate, :text
    remove_column :legislation_processes, :target, :text
  end
end
