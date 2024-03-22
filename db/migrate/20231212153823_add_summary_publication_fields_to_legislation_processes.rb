class AddSummaryPublicationFieldsToLegislationProcesses < ActiveRecord::Migration[6.1]
  def change
    add_column :legislation_processes, :summary_publication_date, :date
    add_column :legislation_processes, :summary_publication_enabled, :boolean
  end
end
