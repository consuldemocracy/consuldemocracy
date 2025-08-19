class AddAdditionalContextToSensemakerJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :sensemaker_jobs, :additional_context, :text
  end
end
