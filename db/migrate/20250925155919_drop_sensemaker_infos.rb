class DropSensemakerInfos < ActiveRecord::Migration[7.1]
  def up
    drop_table :sensemaker_infos
  end

  def down
    create_table :sensemaker_infos do |t|
      t.string :kind
      t.datetime :generated_at
      t.string :script
      t.string :commentable_type, null: false
      t.integer :commentable_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:commentable_type, :commentable_id], name: "index_sensemaker_infos_on_commentable_type_and_commentable_id"
      t.index [:kind, :commentable_type, :commentable_id], name: "index_sensemaker_infos_on_kind_and_commentable", unique: true
    end
  end
end
