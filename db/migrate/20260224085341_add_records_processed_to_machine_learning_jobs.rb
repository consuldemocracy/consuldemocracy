class AddRecordsProcessedToMachineLearningJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :machine_learning_jobs, :records_processed, :integer
  end
end
