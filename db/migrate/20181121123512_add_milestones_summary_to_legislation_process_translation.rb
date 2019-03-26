class AddMilestonesSummaryToLegislationProcessTranslation < ActiveRecord::Migration
  def change
    add_column :legislation_process_translations, :milestones_summary, :text
  end
end
