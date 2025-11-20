class RenameToAnalysableInSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    rename_column :sensemaker_jobs, :commentable_type, :analysable_type
    rename_column :sensemaker_jobs, :commentable_id, :analysable_id

    change_column_null :sensemaker_jobs, :analysable_id, true
  end
end
