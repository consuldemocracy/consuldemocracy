class AddDryRunToMachineLearningJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :machine_learning_jobs, :dry_run, :boolean
  end
end
