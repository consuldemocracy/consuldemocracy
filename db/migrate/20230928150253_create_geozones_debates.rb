class CreateGeozonesDebates < ActiveRecord::Migration[6.0]
  def change
    create_table "geozones_debates", id: :serial, force: :cascade do |t|
      t.integer "geozone_id"
      t.integer "debate_id"
      t.index ["geozone_id"], name: "index_geozones_debates_on_geozone_id"
      t.index ["debate_id"], name: "index_geozones_debates_on_debate_id"
    end
  end
end
