require "rails_helper"
require Rails.root.join("db", "migrate", "20190530082138_add_unique_index_to_local_census_records")

describe "LocalCensusRecord tasks" do
  let(:run_rake_task) do
    Rake::Task["local_census_records:remove_duplicates"].reenable
    Rake.application.invoke_task("local_census_records:remove_duplicates")
  end

  describe "#remove_duplicates" do
    around do |example|
      ActiveRecord::Migration.suppress_messages do
        example.run
      end
    end

    before { AddUniqueIndexToLocalCensusRecords.new.down }
    after { AddUniqueIndexToLocalCensusRecords.new.up }

    it "Remove all duplicates keeping older records" do
      record1 = create(:local_census_record, document_type: "1", document_number: "#DOCUMENT_NUMBER")
      record2 = create(:local_census_record, document_type: "2", document_number: "#DOCUMENT_NUMBER")
      dup_record1 = build(:local_census_record, document_type: "1", document_number: "#DOCUMENT_NUMBER")
      dup_record1.save!(validate: false)
      dup_record2 = build(:local_census_record, document_type: "2", document_number: "#DOCUMENT_NUMBER")
      dup_record2.save!(validate: false)
      record3 = create(:local_census_record, document_type: "3", document_number: "#DOCUMENT_NUMBER")

      expect(LocalCensusRecord.count).to eq(5)

      run_rake_task

      expect(LocalCensusRecord.all).to match_array([record1, record2, record3])
    end
  end
end
