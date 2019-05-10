class CreateCommunity < ActiveRecord::Migration[4.2]
  def change
    create_table :communities do |t|
      t.timestamps null: false
    end
  end
end
