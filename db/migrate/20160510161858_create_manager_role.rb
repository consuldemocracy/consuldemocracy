class CreateManagerRole < ActiveRecord::Migration[4.2]
  def change
    create_table :managers do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
