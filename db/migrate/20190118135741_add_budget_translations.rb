class AddBudgetTranslations < ActiveRecord::Migration[4.2]

  def self.up
    Budget.create_translation_table!(
      {
        name: :string
      },
      { migrate_data: true }
    )
  end

  def self.down
    Budget.drop_translation_table!
  end

end
