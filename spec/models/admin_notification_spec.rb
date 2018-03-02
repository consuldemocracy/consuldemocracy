require 'rails_helper'

describe AdminNotification do
  let(:admin_notification) { build(:admin_notification) }

  it "is valid" do
    expect(admin_notification).to be_valid
  end

  it 'is not valid without a title' do
    admin_notification.title = nil
    expect(admin_notification).not_to be_valid
  end

  it 'is not valid without a body' do
    admin_notification.body = nil
    expect(admin_notification).not_to be_valid
  end

  it 'is not valid without a segment_recipient' do
    admin_notification.segment_recipient = nil
    expect(admin_notification).not_to be_valid
  end

  describe '#complete_link_url' do
    it 'does not change link if there is no value' do
      expect(admin_notification.link).to be_nil
    end

    it 'fixes a link without http://' do
      admin_notification.link = 'lol.consul.dev'

      expect(admin_notification).to be_valid
      expect(admin_notification.link).to eq('http://lol.consul.dev')
    end

    it 'fixes a link with wwww. but without http://' do
      admin_notification.link = 'www.lol.consul.dev'

      expect(admin_notification).to be_valid
      expect(admin_notification.link).to eq('http://www.lol.consul.dev')
    end

    it 'does not modify a link with http://' do
      admin_notification.link = 'http://lol.consul.dev'

      expect(admin_notification).to be_valid
      expect(admin_notification.link).to eq('http://lol.consul.dev')
    end

    it 'does not modify a link with https://' do
      admin_notification.link = 'https://lol.consul.dev'

      expect(admin_notification).to be_valid
      expect(admin_notification.link).to eq('https://lol.consul.dev')
    end

    it 'does not modify a link with http://wwww.' do
      admin_notification.link = 'http://www.lol.consul.dev'

      expect(admin_notification).to be_valid
      expect(admin_notification.link).to eq('http://www.lol.consul.dev')
    end
  end

  describe '#valid_segment_recipient?' do
    it 'is false when segment_recipient value is invalid' do
      admin_notification.update(segment_recipient: 'invalid_segment_name')
      error = 'The user recipients segment is invalid'

      expect(admin_notification).not_to be_valid
      expect(admin_notification.errors.messages[:segment_recipient]).to include(error)
    end
  end

  describe '#list_of_recipients' do
    let(:erased_user) { create(:user, username: 'erased_user') }

    before do
      2.times { create(:user) }
      erased_user.erase
      admin_notification.update(segment_recipient: 'all_users')
    end

    it 'returns list of all active users' do
      expect(admin_notification.list_of_recipients.count).to eq(2)
      expect(admin_notification.list_of_recipients).not_to include(erased_user)
    end
  end

end
