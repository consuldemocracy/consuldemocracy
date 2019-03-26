class AddBudgetHeadingTranslations < ActiveRecord::Migration

  def self.up
    Budget::Heading.create_translation_table!(
      {
        name: :string
      },
      { migrate_data: true }
    )
  end

  def self.down
    Budget::Heading.drop_translation_table!
  end

end
