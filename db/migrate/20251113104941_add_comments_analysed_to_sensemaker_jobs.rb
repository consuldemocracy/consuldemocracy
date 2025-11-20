class AddCommentsAnalysedToSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :sensemaker_jobs, :comments_analysed, :integer, default: 0
  end
end
