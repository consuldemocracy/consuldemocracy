class CreateAdministratorTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :administrator_tasks do |t|
      t.references :source, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true
      t.datetime :executed_at

      t.timestamps null: false
    end
  end
end
