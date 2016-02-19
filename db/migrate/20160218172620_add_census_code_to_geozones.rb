class AddCensusCodeToGeozones < ActiveRecord::Migration
  def change
    add_column :geozones, :census_code, :string
  end
end
