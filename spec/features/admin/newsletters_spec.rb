require 'rails_helper'

feature 'Admin newsletters emails' do

  let(:download_button_text) { 'Download zip with users list' }

  background do
    @admin = create(:administrator)
    @newsletter_user = create(:user, newsletter: true)
    @non_newsletter_user = create(:user, newsletter: false)
    login_as(@admin.user)
    visit admin_newsletters_path
  end

  scenario 'Index' do
    expect(page).to have_content download_button_text
  end

  scenario 'Download newsletter email zip' do
    click_link download_button_text
    downloaded_file_content = Zip::InputStream.open(StringIO.new(page.body)).get_next_entry.get_input_stream {|is| is.read }
    expect(downloaded_file_content).to include(@admin.user.email, @newsletter_user.email)
    expect(downloaded_file_content).not_to include(@non_newsletter_user.email)
  end
end

