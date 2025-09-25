class AddParentJobToSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    add_reference :sensemaker_jobs, :parent_job, foreign_key: { to_table: :sensemaker_jobs }
  end
end
