class AddMilestonesSummaryToLegislationProcessTranslation < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_process_translations, :milestones_summary, :text
  end
end
