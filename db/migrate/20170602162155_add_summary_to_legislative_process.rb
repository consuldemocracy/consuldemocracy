class AddSummaryToLegislativeProcess < ActiveRecord::Migration
  def change
    add_column :legislation_processes, :summary, :text, limit: 280
  end
end
