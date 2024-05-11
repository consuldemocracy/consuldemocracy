class DropCampaigns < ActiveRecord::Migration[7.0]
  def change
    drop_table :campaigns, id: :serial do |t|
      t.string :name
      t.string :track_id
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false
    end
  end
end
