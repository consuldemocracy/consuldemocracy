require "rails_helper"

describe Image do
  it_behaves_like "image validations", "budget_investment_image"
  it_behaves_like "image validations", "proposal_image"

  it "stores attachments with Active Storage" do
    image = create(:image, attachment: fixture_file_upload("clippy.jpg"))

    expect(image.attachment).to be_attached
    expect(image.attachment.filename).to eq "clippy.jpg"
  end
end
