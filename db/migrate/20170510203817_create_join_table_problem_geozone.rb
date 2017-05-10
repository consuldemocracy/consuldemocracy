class CreateJoinTableProblemGeozone < ActiveRecord::Migration
  def change
    create_join_table :problems, :geozones do |t|
      # t.index [:problem_id, :geozone_id]
      # t.index [:geozone_id, :problem_id]
    end
  end
end
