shared_examples "document validations" do |documentable_factory|

  let(:document) { build(:document, documentable_factory.to_sym) }

  it "should be valid" do
    expect(document).to be_valid
  end

  it "should not be valid without a title" do
    document.title = nil

    expect(document).to_not be_valid
  end

  it "should not be valid without an attachment" do
    document.attachment = nil

    expect(document).to_not be_valid
  end

  it "should not be valid for attachment images" do
    document.attachment = File.new("spec/fixtures/files/logo_header.png")

    expect(document).to_not be_valid
  end

  it "should not be valid for attachment 3MB" do
    document.stub(:attachment_file_size).and_return(3.1.megabytes)

    document.should_not be_valid
    expect(document.errors[:attachment]).to include "must be in between 0 Bytes and 3 MB"
  end

  it "should not be valid without a user_id" do
    document.user_id = nil

    expect(document).to_not be_valid
  end

  it "should not be valid without a documentable_id" do
    document.documentable_id = nil

    expect(document).to_not be_valid
  end

  it "should not be valid without a documentable_type" do
    document.documentable_type = nil

    expect(document).to_not be_valid
  end

end
