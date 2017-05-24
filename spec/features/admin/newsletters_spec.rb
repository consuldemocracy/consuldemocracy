require 'rails_helper'

feature 'Admin newsletters emails' do

  let(:download_button_text) { 'Download zip with users list' }

  background do
    @admin = create(:administrator)
    login_as(@admin.user)
    visit admin_newsletters_path
  end

  scenario 'Index' do
    expect(page).to have_content download_button_text
  end

  scenario 'Download newsletter email zip' do
    click_link download_button_text
    expect( Zip::InputStream.open(StringIO.new(page.body)).get_next_entry.get_input_stream {|is| is.read } ).to include @admin.user.email
  end
end

