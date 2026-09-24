class AddCliFlagsToSensemakerJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :sensemaker_jobs, :cli_flags, :jsonb, null: false, default: {}
  end
end
