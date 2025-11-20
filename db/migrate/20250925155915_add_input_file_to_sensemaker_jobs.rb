class AddInputFileToSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :sensemaker_jobs, :input_file, :string
  end
end
