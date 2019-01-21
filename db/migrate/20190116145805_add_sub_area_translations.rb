class AddSubAreaTranslations < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        SubArea.create_translation_table!({
          :name => :string,
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        SubArea.drop_translation_table! :migrate_data => true
      end
    end
  end
end
