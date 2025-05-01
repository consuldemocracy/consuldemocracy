class CreateProcessManagerRole < ActiveRecord::Migration[7.0]
  def change
    create_table :process_managers do |t|
      t.belongs_to :user, index: true, foreign_key: true
      
      t.timestamps
    end
  end
end
