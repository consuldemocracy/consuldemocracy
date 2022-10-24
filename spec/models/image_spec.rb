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

# == Schema Information
#
# Table name: images
#
#  id                      :integer          not null, primary key
#  imageable_id            :integer
#  imageable_type          :string
#  title                   :string(80)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  user_id                 :integer
#
