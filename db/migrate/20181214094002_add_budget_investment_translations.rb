class AddBudgetInvestmentTranslations < ActiveRecord::Migration[4.2]
  def self.up
    Budget::Investment::Translation.without_auditing do
      Budget::Investment.create_translation_table!(
        {
          title:               :string,
          description:         :text
        },
        { migrate_data: true }
      )
    end
  end

  def self.down
    Budget::Investment.drop_translation_table!
  end
end
