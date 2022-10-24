class AddCensusCodeToGeozones < ActiveRecord::Migration[4.2]
  def change
    add_column :geozones, :census_code, :string
  end
end
