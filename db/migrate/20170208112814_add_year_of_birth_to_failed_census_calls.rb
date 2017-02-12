class AddYearOfBirthToFailedCensusCalls < ActiveRecord::Migration
  def change
    add_column :failed_census_calls, :year_of_birth, :integer
  end
end
