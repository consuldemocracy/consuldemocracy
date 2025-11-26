class AddPersistedOutputToSensemakerJobs < ActiveRecord::Migration[7.1]
  def up
    add_column :sensemaker_jobs, :persisted_output, :string

    begin
      Sensemaker::Job.find_each(&:save!)
    rescue => e
      Rails.logger.error("Error calling save! in attempt to trigger save callbacks for jobs: #{e.message}")
    end
  end

  def down
    remove_column :sensemaker_jobs, :persisted_output
  end
end
