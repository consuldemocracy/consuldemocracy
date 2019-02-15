class AddBudgetPhaseTranslations < ActiveRecord::Migration

  def self.up
    Budget::Phase.create_translation_table!(
      {
        description: :text,
        summary: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    Budget::Phase.drop_translation_table!
  end

end
