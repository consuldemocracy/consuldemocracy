class AddSummaryToLegislativeProcess < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :summary, :text, limit: 280
  end
end
