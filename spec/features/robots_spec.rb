require 'rails_helper'

feature 'Robots' do

  scenario "allow bing robots to index the site" do
    visit '/robots.txt'

    expect(page).not_to have_content('User-Agent: bingbot')

    Setting['feature.prevent_bing_from_index_consul'] = nil

    visit '/robots.txt'

    expect(page).to have_content('User-Agent: bingbot')

    Setting['feature.prevent_bing_from_index_consul'] = "active"

  end

end

