shared_examples "document validations" do |documentable_factory|
  include DocumentablesHelper

  let!(:document)               { build(:document, documentable_factory.to_sym) }
  let!(:maxfilesize)            { max_file_size(document.documentable.class) }
  let!(:acceptedcontenttypes)   { accepted_content_types(document.documentable.class) }

  it "is valid" do
    expect(document).to be_valid
  end

  it "is not valid without a title" do
    document.title = nil

    expect(document).not_to be_valid
  end

  it "is not valid without an attachment" do
    document.attachment = nil

    expect(document).not_to be_valid
  end

  it "is valid for all accepted content types" do
    acceptedcontenttypes.each do |content_type|
      extension = content_type.split("/").last
      document.attachment = File.new("spec/fixtures/files/empty.#{extension}")

      expect(document).to be_valid
    end
  end

  it "is not valid for attachments larger than documentable max_file_size definition" do
    allow(document).to receive(:attachment_file_size).and_return(maxfilesize.megabytes + 1.byte)
    max_size_error_message = "must be in between 0 Bytes and #{maxfilesize} MB"

    expect(document).not_to be_valid
    expect(document.errors[:attachment]).to include max_size_error_message
  end

  it "is not valid without a user_id" do
    document.user_id = nil

    expect(document).not_to be_valid
  end

  it "is not valid without a documentable_id" do
    document.save!
    document.documentable_id = nil

    expect(document).not_to be_valid
  end

  it "is not valid without a documentable_type" do
    document.save!
    document.documentable_type = nil

    expect(document).not_to be_valid
  end
end
