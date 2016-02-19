class AddDistrictCodeToFailedCensusCall < ActiveRecord::Migration
  def change
    add_column :failed_census_calls, :district_code, :string
  end
end
