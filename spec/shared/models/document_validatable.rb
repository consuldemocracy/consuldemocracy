shared_examples "document validations" do |documentable_factory|

  let(:documentable) { build(:document, documentable_factory.to_sym) }

  it "should be valid" do
    expect(documentable).to be_valid
  end

  it "should not be valid without a user_id" do
    documentable.user_id = nil

    expect(documentable).to_not be_valid
  end

  it "should not be valid without a documentable_id" do
    documentable.documentable_id = nil

    expect(documentable).to_not be_valid
  end

  it "should not be valid without a documentable_type" do
    documentable.documentable_type = nil

    expect(documentable).to_not be_valid
  end

end
