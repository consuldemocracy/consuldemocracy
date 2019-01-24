require 'rails_helper'

feature 'Banner' do

  scenario "The banner is shown correctly" do
    create(:web_section, name: 'debates')
    banner = create(:banner, title: 'Hello',
                      description: 'Banner description',
                      target_url:  'http://www.url.com',
                      post_started_at: (Time.current - 4.days),
                      post_ended_at:   (Time.current + 10.days),
                      background_color: '#FF0000',
                      font_color: '#FFFFFF')
    section = WebSection.where(name: 'debates').last
    create(:banner_section, web_section: section, banner_id: banner.id)

    visit debates_path

    within('.banner') do
      expect(page).to have_content('Banner description')
      expect(find('h2')[:style]).to eq("color:#{banner.font_color}")
      expect(find('h3')[:style]).to eq("color:#{banner.font_color}")
    end

    visit root_path

    expect(page).not_to have_content('Banner description')

    visit proposals_path

    expect(page).not_to have_content('Banner description')
  end
end
