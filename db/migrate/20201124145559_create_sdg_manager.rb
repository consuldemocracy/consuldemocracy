class CreateSDGManager < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_managers do |t|
      t.belongs_to :user, foreign_key: true, index: { unique: true }
      t.timestamps
    end
  end
end
