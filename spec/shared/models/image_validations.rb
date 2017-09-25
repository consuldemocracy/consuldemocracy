shared_examples "image validations" do |imageable_factory|
  include ImagesHelper
  include ImageablesHelper

  let!(:image)                  { build(:image, imageable_factory.to_sym) }
  let!(:imageable)              { image.imageable }
  let!(:acceptedcontenttypes)   { imageable_accepted_content_types }

  it "should be valid" do
    expect(image).to be_valid
  end

  it "should not be valid without a title" do
    image.title = nil

    expect(image).to_not be_valid
  end

  it "should not be valid without an attachment" do
    image.attachment = nil

    expect(image).to_not be_valid
  end

  it "should be valid for all accepted content types" do
    acceptedcontenttypes.each do |content_type|
      extension = content_type.split("/").last
      image.attachment = File.new("spec/fixtures/files/clippy.#{extension}")

      expect(image).to be_valid
    end
  end

  it "should not be valid for png and gif image content types" do
    ["gif", "png"].each do |content_type|
      extension = content_type.split("/").last
      image.attachment = File.new("spec/fixtures/files/clippy.#{extension}")

      expect(image).not_to be_valid
    end
  end

  it "should not be valid for attachments larger than imageable max_file_size definition" do
    allow(image).to receive(:attachment_file_size).and_return(Image::MAX_IMAGE_SIZE + 1.byte)

    expect(image).to_not be_valid
    expect(image.errors[:attachment]).to include "must be in between 0 Bytes and 1 MB"
  end

  it "should not be valid without a user_id" do
    image.user_id = nil

    expect(image).to_not be_valid
  end

  it "should not be valid without a imageable_id" do
    image.save
    image.imageable_id = nil

    expect(image).to_not be_valid
  end

  it "should not be valid without a imageable_type" do
    image.save
    image.imageable_type = nil

    expect(image).to_not be_valid
  end

end