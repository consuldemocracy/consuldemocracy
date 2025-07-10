class AddIndexToLocalCensusRecordsDocumentNumber < ActiveRecord::Migration[5.0]
  def change
    add_index :local_census_records, :document_number
  end
end
