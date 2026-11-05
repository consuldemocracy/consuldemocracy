class RemoveMachineLearningJobsForeignKey < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :machine_learning_jobs, :users
  end
end
