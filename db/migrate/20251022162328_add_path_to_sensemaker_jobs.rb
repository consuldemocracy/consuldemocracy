class AddPathToSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :sensemaker_jobs, :path, :text
  end
end
