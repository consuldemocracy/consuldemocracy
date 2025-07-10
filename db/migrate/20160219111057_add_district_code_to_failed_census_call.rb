class AddDistrictCodeToFailedCensusCall < ActiveRecord::Migration[4.2]
  def change
    add_column :failed_census_calls, :district_code, :string
  end
end
