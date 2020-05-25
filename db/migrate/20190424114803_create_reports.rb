class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.boolean :stats
      t.boolean :results
      t.references :process, polymorphic: true

      t.timestamps null: false
    end
  end
end
