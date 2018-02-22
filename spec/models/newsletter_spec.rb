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

  it 'is not valid with an inexistent user segment for segment_recipient' do
    newsletter.segment_recipient = 'invalid_user_segment_name'
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

  describe '#valid_segment_recipient?' do
    it 'is false when segment_recipient value is invalid' do
      newsletter.update(segment_recipient: 'invalid_segment_name')
      error = 'The user recipients segment is invalid'

      expect(newsletter).not_to be_valid
      expect(newsletter.errors.messages[:segment_recipient]).to include(error)
    end
  end

  describe '#list_of_recipients' do
    let(:erased_user) { create(:user, username: 'erased_user') }

    before do
      create(:user, newsletter: true, username: 'newsletter_user')
      create(:user, newsletter: false)
      erased_user.erase
      newsletter.update(segment_recipient: 'all_users')
    end

    it 'returns list of recipients excluding users with disabled newsletter' do
      expect(newsletter.list_of_recipients.count).to eq(1)
      expect(newsletter.list_of_recipients.first.username).to eq('newsletter_user')
      expect(newsletter.list_of_recipients).not_to include(erased_user)
    end
  end
end
