class AddAreaTranslations < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Area.create_translation_table!({
          :name => :string,
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        Area.drop_translation_table! :migrate_data => true
      end
    end
  end
end
