class AddPersistedOutputToSensemakerJobs < ActiveRecord::Migration[7.1]
  def up
    add_column :sensemaker_jobs, :persisted_output, :string

    for job in Sensemaker::Job.all
      job.update!(persisted_output: Sensemaker::JobRunner.new(job).output_file) if !job.errored? && job.finished?
    end
  end

  def down
    remove_column :sensemaker_jobs, :persisted_output
  end
end
