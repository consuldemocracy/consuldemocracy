shared_examples "document validations" do |documentable_factory|

  let(:document)      { build(:document, documentable_factory.to_sym) }
  let(:max_file_size) { document.documentable.class.max_file_size }
  let(:accepted_content_types) { document.documentable.class.accepted_content_types }

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

  it "should be valid for all accepted content types" do
    accepted_content_types.each do |content_type|
      extension = content_type.split("/").last
      document.attachment = File.new("spec/fixtures/files/empty.#{extension}")

      expect(document).to be_valid
    end
  end

  it "should not be valid for attachments larger than documentable max_file_size definition" do
    document.stub(:attachment_file_size).and_return(max_file_size.bytes + 1.byte)

    expect(document).to_not be_valid
    expect(document.errors[:attachment]).to include "must be in between 0 Bytes and #{bytesToMeg(max_file_size)} MB"
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

def bytesToMeg(bytes)
  bytes / (1024.0 * 1024.0)
end