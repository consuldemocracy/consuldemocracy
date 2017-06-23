class CreateJoinTableProposalGeozone < ActiveRecord::Migration
  def change
    create_join_table :proposals, :geozones do |t|
      # t.index [:problem_id, :geozone_id]
      # t.index [:geozone_id, :problem_id]
    end
  end
end
