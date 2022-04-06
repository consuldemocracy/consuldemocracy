require "rails_helper"

describe Image do
  it_behaves_like "image validations", "budget_investment_image"
  it_behaves_like "image validations", "proposal_image"

  it "stores attachments with both Paperclip and Active Storage" do
    image = create(:image, attachment: File.new("spec/fixtures/files/clippy.jpg"))

    expect(image.attachment).to exist
    expect(image.attachment_file_name).to eq "clippy.jpg"

    expect(image.storage_attachment).to be_attached
    expect(image.storage_attachment.filename).to eq "clippy.jpg"
  end
end
