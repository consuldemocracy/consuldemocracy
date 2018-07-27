class CreateActivePolls < ActiveRecord::Migration
  def change
    create_table :active_polls do |t|
      t.text       :description

      t.datetime   :created_at, null: false
      t.datetime   :updated_at, null: false
    end
  end
end
