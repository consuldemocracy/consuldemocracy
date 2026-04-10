class AddConfigToMachineLearningJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :machine_learning_jobs, :config, :jsonb, default: {}
  end
end
