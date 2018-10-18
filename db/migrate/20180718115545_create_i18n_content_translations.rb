class CreateI18nContentTranslations < ActiveRecord::Migration
  def change
    create_table :i18n_contents do |t|
      t.string :key
    end

    reversible do |dir|
      dir.up do
        I18nContent.create_translation_table! :value => :text
      end

      dir.down do
        I18nContent.drop_translation_table!
      end
    end
  end
end
