class CreateJoinTableProjectGeozone < ActiveRecord::Migration
  def change
    create_join_table :projects, :geozones do |t|
      # t.index [:project_id, :geozone_id]
      # t.index [:geozone_id, :project_id]
    end
  end
end
