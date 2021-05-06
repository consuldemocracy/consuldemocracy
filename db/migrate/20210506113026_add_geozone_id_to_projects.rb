class AddGeozoneIdToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :geozone_id, :integer
  end
end
