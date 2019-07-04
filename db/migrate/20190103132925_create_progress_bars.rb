class CreateProgressBars < ActiveRecord::Migration
  def change
    create_table :progress_bars do |t|
      t.integer :kind
      t.integer :percentage
      t.references :progressable, polymorphic: true

      t.timestamps null: false
    end

    reversible do |change|
      change.up do
        ProgressBar.create_translation_table!({
          title: :string
        })
      end

      change.down do
        ProgressBar.drop_translation_table!
      end
    end
  end
end
