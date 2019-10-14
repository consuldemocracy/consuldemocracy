class CreateManagerRole < ActiveRecord::Migration
  def change
    create_table :managers do |t|
      t.belongs_to :user, index: true, foreign_key: true
    end
  end
end
