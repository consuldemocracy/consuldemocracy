class AddYearOfBirthToFailedCensusCalls < ActiveRecord::Migration[4.2]
  def change
    add_column :failed_census_calls, :year_of_birth, :integer
  end
end
