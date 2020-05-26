class AddUniqueIndexToLocalCensusRecords < ActiveRecord::Migration[5.0]
  def up
    add_index :local_census_records, [:document_number, :document_type], unique: true
  end

  def down
    remove_index :local_census_records, [:document_number, :document_type]
  end
end
