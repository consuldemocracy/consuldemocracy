require 'rails_helper'

describe Newsletter do
  let(:newsletter) { build(:newsletter) }

  it "is valid" do
    expect(newsletter).to be_valid
  end

  it 'is not valid without a subject' do
    newsletter.subject = nil
    expect(newsletter).not_to be_valid
  end

  it 'is not valid without a segment_recipient' do
    newsletter.segment_recipient = nil
    expect(newsletter).not_to be_valid
  end

  it 'is not valid without a from' do
    newsletter.from = nil
    expect(newsletter).not_to be_valid
  end

  it 'is not valid without a body' do
    newsletter.body = nil
    expect(newsletter).not_to be_valid
  end

  it 'validates from attribute email format' do
    newsletter.from = "this_is_not_an_email"
    expect(newsletter).not_to be_valid
  end
end
