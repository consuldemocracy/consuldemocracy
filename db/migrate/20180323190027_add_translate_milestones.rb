class AddTranslateMilestones < ActiveRecord::Migration
  def self.up
    Budget::Investment::Milestone.create_translation_table!(
      {
        title:       :string,
        description: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    Budget::Investment::Milestone.drop_translation_table!
  end
end
