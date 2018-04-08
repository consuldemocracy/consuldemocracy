class CreateCommunity < ActiveRecord::Migration
  def change
    create_table :communities do |t|
      t.timestamps null: false
    end
  end
end
