require "rails_helper"

describe "active storage tasks" do
  describe "migrate_from_paperclip" do
    let(:run_rake_task) do
      Rake::Task["active_storage:migrate_from_paperclip"].reenable
      Rake.application.invoke_task("active_storage:migrate_from_paperclip")
    end

    let(:storage_root) { ActiveStorage::Blob.service.root }
    before { FileUtils.rm_rf storage_root }

    it "migrates records and attachments" do
      document = create(:document,
                        attachment: nil,
                        paperclip_attachment: File.new("spec/fixtures/files/clippy.pdf"))

      expect(ActiveStorage::Attachment.count).to eq 0
      expect(ActiveStorage::Blob.count).to eq 0
      expect(test_storage_file_paths.count).to eq 0

      run_rake_task
      document.reload

      expect(ActiveStorage::Attachment.count).to eq 1
      expect(ActiveStorage::Blob.count).to eq 1
      expect(document.storage_attachment.filename).to eq "clippy.pdf"
      expect(test_storage_file_paths.count).to eq 1
      expect(storage_file_path(document)).to eq test_storage_file_paths.first
    end

    it "migrates records with deleted files ignoring the files" do
      document = create(:document,
                        attachment: nil,
                        paperclip_attachment: File.new("spec/fixtures/files/clippy.pdf"))
      FileUtils.rm(document.attachment.path)

      run_rake_task
      document.reload

      expect(ActiveStorage::Attachment.count).to eq 1
      expect(ActiveStorage::Blob.count).to eq 1
      expect(document.storage_attachment.filename).to eq "clippy.pdf"
      expect(test_storage_file_paths.count).to eq 0
    end

    it "does not migrate already migrated records" do
      document = create(:document, attachment: File.new("spec/fixtures/files/clippy.pdf"))

      migrated_file = test_storage_file_paths.first
      attachment_id = document.storage_attachment.attachment.id
      blob_id = document.storage_attachment.blob.id

      run_rake_task
      document.reload

      expect(ActiveStorage::Attachment.count).to eq 1
      expect(ActiveStorage::Blob.count).to eq 1
      expect(document.storage_attachment.attachment.id).to eq attachment_id
      expect(document.storage_attachment.blob.id).to eq blob_id

      expect(test_storage_file_paths.count).to eq 1
      expect(storage_file_path(document)).to eq migrated_file
      expect(test_storage_file_paths.first).to eq migrated_file
    end

    it "does not migrate files for deleted records" do
      document = create(:document, attachment: File.new("spec/fixtures/files/clippy.pdf"))
      FileUtils.rm storage_file_path(document)
      Document.delete_all

      run_rake_task

      expect(ActiveStorage::Attachment.count).to eq 1
      expect(ActiveStorage::Blob.count).to eq 1
      expect(document.storage_attachment.filename).to eq "clippy.pdf"
      expect(test_storage_file_paths.count).to eq 0
    end

    def test_storage_file_paths
      Dir.glob("#{storage_root}/**/*").select { |file_or_folder| File.file?(file_or_folder) }
    end

    def storage_file_path(record)
      ActiveStorage::Blob.service.path_for(record.storage_attachment.blob.key)
    end
  end
end
