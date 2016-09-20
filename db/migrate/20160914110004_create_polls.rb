class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.string :name
    end
  end
end
