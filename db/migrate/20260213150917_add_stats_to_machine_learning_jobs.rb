class AddStatsToMachineLearningJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :machine_learning_jobs, :duration, :integer
    add_column :machine_learning_jobs, :total_tokens, :integer
  end
end
