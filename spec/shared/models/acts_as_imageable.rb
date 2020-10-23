shared_examples "acts as imageable" do |imageable_factory|
  let!(:image) { build(:image, imageable_factory.to_sym) }

  it "is valid" do
    expect(image).to be_valid
  end

  describe "file extension" do
    it "is not valid with '.png' extension" do
      image.attachment = File.new("spec/fixtures/files/clippy.png")

      expect(image).not_to be_valid
      expect(image.errors[:attachment].size).to eq(1)
    end

    it "is not valid with '.gif' extension" do
      image.attachment = File.new("spec/fixtures/files/clippy.gif")

      expect(image).not_to be_valid
      expect(image.errors[:attachment].size).to eq(1)
    end

    it "is valid with '.jpg' extension" do
      image.attachment = File.new("spec/fixtures/files/clippy.jpg")

      expect(image).to be_valid
    end
  end

  describe "image dimmessions" do
    it "is valid when image dimmessions are 475X475 at least" do
      expect(image).to be_valid
    end

    it "is not valid when image dimmensions are smaller than 475X475" do
      image.attachment = File.new("spec/fixtures/files/logo_header.jpg")

      expect(image).not_to be_valid
    end
  end

  describe "title" do
    it "is not valid when correct image attached but no image title provided" do
      image.title = ""

      expect(image).not_to be_valid
    end

    it "is not valid when image title is too short" do
      image.title = "a" * 3

      expect(image).not_to be_valid
    end

    it "is not valid when image title is too long" do
      image.title = "a" * 81

      expect(image).not_to be_valid
    end
  end

  it "image destroy should remove image from file storage" do
    image.save!
    image_url = image.attachment.url
    new_url = "/attachments/original/missing.png"

    expect { image.attachment.destroy }.to change { image.attachment.url }.from(image_url).to(new_url)
  end
end
