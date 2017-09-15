require 'rails_helper'

describe DirectUpload do

  it "should be valid for different kind of combinations when attachment is valid" do
    expect(build(:direct_upload, :proposal, :documents)).to be_valid
    expect(build(:direct_upload, :proposal, :image)).to be_valid
    expect(build(:direct_upload, :budget_investment, :documents)).to be_valid
    expect(build(:direct_upload, :budget_investment, :image)).to be_valid
  end

  it "should not be valid for different kind of combinations when invalid atttachment content types" do
    expect(build(:direct_upload, :proposal, :documents, attachment: File.new("spec/fixtures/files/clippy.png"))).not_to be_valid
    expect(build(:direct_upload, :proposal, :image, attachment: File.new("spec/fixtures/files/empty.pdf"))).not_to be_valid
    expect(build(:direct_upload, :budget_investment, :documents, attachment: File.new("spec/fixtures/files/clippy.png"))).not_to be_valid
    expect(build(:direct_upload, :budget_investment, :image, attachment: File.new("spec/fixtures/files/empty.pdf"))).not_to be_valid
  end

end