require 'rails_helper'

feature 'Social media meta tags' do

  context 'Setting social media meta tags' do

    before do
      Setting['meta_keywords'] = "citizen, participation, open government"
      Setting['meta_title'] = "CONSUL"
      Setting['meta_description'] = "Citizen Participation and Open Government Application"
    end

    after do
      Setting['meta_keywords'] = nil
      Setting['meta_title'] = nil
      Setting['meta_description'] = nil
    end

    scenario 'Social media meta tags partial render settings content' do

      visit root_path

      expect(page).to have_css 'meta[name="keywords"][content="citizen, participation, open government"]', visible: false
      expect(page).to have_css 'meta[name="twitter:title"][content="CONSUL"]', visible: false
      expect(page).to have_css 'meta[name="twitter:title"][content="CONSUL"]', visible: false
      expect(page).to have_css 'meta[property="og:title"][content="CONSUL"]', visible: false
      expect(page).to have_css 'meta[property="og:description"][content="Citizen Participation and Open Government Application"]', visible: false
    end
  end

end
