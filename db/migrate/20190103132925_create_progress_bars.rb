class CreateProgressBars < ActiveRecord::Migration[4.2]
  def change
    create_table :progress_bars, id: :serial do |t|
      t.integer :kind
      t.integer :percentage
      t.string :progressable_type
      t.integer :progressable_id

      t.timestamps null: false
    end

    create_table :progress_bar_translations do |t|
      t.integer :progress_bar_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title

      t.index :locale
      t.index :progress_bar_id
    end
  end
end
