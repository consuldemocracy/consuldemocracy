require "rails_helper"

describe "active storage tasks" do
  describe "remove_paperclip_compatibility_in_existing_attachments" do
    let(:run_rake_task) do
      Rake::Task["active_storage:remove_paperclip_compatibility_in_existing_attachments"].reenable
      Rake.application.invoke_task("active_storage:remove_paperclip_compatibility_in_existing_attachments")
    end

    it "updates old regular attachments" do
      document = create(:document)
      image = create(:image)
      site_customization_image = create(:site_customization_image)

      document.attachment.attachment.update_column(:name, "storage_attachment")
      image.attachment.attachment.update_column(:name, "storage_attachment")
      site_customization_image.image.attachment.update_column(:name, "storage_image")

      document.reload
      image.reload
      site_customization_image.reload

      expect(document.attachment.attachment).to be nil
      expect(image.attachment.attachment).to be nil
      expect(site_customization_image.image.attachment).to be nil

      run_rake_task
      document.reload
      image.reload
      site_customization_image.reload

      expect(document.attachment.attachment.name).to eq "attachment"
      expect(image.attachment.attachment.name).to eq "attachment"
      expect(site_customization_image.reload.image.attachment.name).to eq "image"
    end

    it "does not modify old ckeditor attachments" do
      image = Ckeditor::Picture.create!(data: fixture_file_upload("clippy.png"))

      expect(image.storage_data.attachment.name).to eq "storage_data"

      run_rake_task
      image.reload

      expect(image.storage_data.attachment.name).to eq "storage_data"
    end

    it "does not modify new regular attachments" do
      document = create(:document)
      image = create(:image)
      site_customization_image = create(:site_customization_image)

      expect(document.attachment.attachment.name).to eq "attachment"
      expect(image.attachment.attachment.name).to eq "attachment"
      expect(site_customization_image.image.attachment.name).to eq "image"

      run_rake_task
      document.reload
      image.reload
      site_customization_image.reload

      expect(document.attachment.attachment.name).to eq "attachment"
      expect(image.attachment.attachment.name).to eq "attachment"
      expect(site_customization_image.reload.image.attachment.name).to eq "image"
    end
  end
end
