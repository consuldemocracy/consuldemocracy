class CreateSensemakerInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :sensemaker_infos do |t|
      t.string :kind
      t.datetime :generated_at
      t.string :script
      t.string :commentable_type, null: false
      t.integer :commentable_id, null: false

      t.timestamps
    end

    add_index :sensemaker_infos, [:commentable_type, :commentable_id]
    add_index :sensemaker_infos, [:kind, :commentable_type, :commentable_id],
              unique: true, name: "index_sensemaker_infos_on_kind_and_commentable"
  end
end
