shared_examples "acts as imageable" do |imageable_factory|

  let!(:image)                  { build(:image, imageable_factory.to_sym) }
  let!(:imageable)              { image.imageable }

  it "should be valid" do
    expect(image).to be_valid
  end

  describe "file extension" do

    it "should not be valid with '.png' extension" do
      image.attachment = File.new("spec/fixtures/files/clippy.png")

      expect(image).to_not be_valid
      expect(image.errors[:attachment].size).to eq(1)
    end

    it "should not be valid with '.gif' extension" do
      image.attachment = File.new("spec/fixtures/files/clippy.gif")

      expect(image).to_not be_valid
      expect(image.errors[:attachment].size).to eq(1)
    end

    it "should be valid with '.jpg' extension" do
      image.attachment = File.new("spec/fixtures/files/clippy.jpg")

      expect(image).to be_valid
    end

  end

  describe "image dimmessions" do

    it "should be valid when image dimmessions are 475X475 at least" do
      expect(image).to be_valid
    end

    it "should not be valid when image dimmensions are smaller than 475X475" do
      image.attachment = File.new("spec/fixtures/files/logo_header.jpg")

      expect(image).not_to be_valid
    end
  end

  describe "title" do

    it "should not be valid when correct image attached but no image title provided" do
      image.title = ''

      expect(image).to_not be_valid
    end

    it "should not be valid when image title is too short" do
      image.title = 'a' * 3

      expect(image).to_not be_valid
    end

    it "should not be valid when image title is too long" do
      image.title = 'a' * 81

      expect(image).to_not be_valid
    end

  end

  it "image destroy should remove image from file storage" do
    image.save
    image_url = image.attachment.url

    expect{ image.attachment.destroy }.to change{ image.attachment.url }.from(image_url).to("/attachments/original/missing.png")
  end

end