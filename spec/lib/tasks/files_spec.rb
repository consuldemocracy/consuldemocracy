require "rails_helper"

describe "files tasks" do
  describe "remove_old_cached_attachments" do
    let(:run_rake_task) do
      Rake::Task["files:remove_old_cached_attachments"].reenable
      Rake.application.invoke_task("files:remove_old_cached_attachments")
    end

    it "deletes old cached attachments" do
      image = build(:image)
      document = build(:document)

      image.attachment.blob.save!
      image.attachment_changes["attachment"].upload
      document.attachment.blob.save!
      document.attachment_changes["attachment"].upload

      travel_to(2.days.from_now) { run_rake_task }

      expect(File.exists?(image.file_path)).to be false
      expect(File.exists?(document.file_path)).to be false
    end

    it "does not delete recent cached attachments" do
      image = build(:image)
      document = build(:document)

      image.attachment.blob.save!
      image.attachment_changes["attachment"].upload
      document.attachment.blob.save!
      document.attachment_changes["attachment"].upload

      travel_to(2.minutes.from_now) { run_rake_task }

      expect(File.exists?(image.file_path)).to be true
      expect(File.exists?(document.file_path)).to be true
    end

    it "does not delete old regular attachments" do
      image = create(:image)
      document = create(:document)

      travel_to(2.days.from_now) { run_rake_task }

      expect(File.exists?(image.file_path)).to be true
      expect(File.exists?(document.file_path)).to be true
    end
  end
end
