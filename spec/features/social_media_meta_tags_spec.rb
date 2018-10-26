require 'rails_helper'

feature 'Social media meta tags' do

  context 'Setting social media meta tags' do

    let(:meta_keywords) { 'citizen, participation, open government' }
    let(:meta_title) { 'Register and support proposals to improve Madrid' }
    let(:meta_description) { "On the city council's citizen participation website you "\
                             "build Madrid. Register, propose and support proposals to reach "\
                             "27,000 signatures."}
    let(:twitter_handle) { '@consul_test' }
    let(:url) { 'http://consul.dev' }
    let(:facebook_handle) { 'consultest' }
    let(:org_name) { 'CONSUL TEST' }

    before do
      Setting['meta_keywords'] = meta_keywords
      Setting['twitter_handle'] = twitter_handle
      Setting['url'] = url
      Setting['facebook_handle'] = facebook_handle
      Setting['org_name'] = org_name
    end

    after do
      Setting['meta_keywords'] = nil
      Setting['twitter_handle'] = nil
      Setting['url'] = 'http://example.com'
      Setting['facebook_handle'] = nil
      Setting['org_name'] = 'Decide Madrid'
    end

    scenario 'Social media meta tags partial render settings content' do

      visit root_path

      expect(page).to have_css 'meta[name="keywords"][content="' + meta_keywords + '"]',
                                visible: false

      expect(page).to have_css 'meta[name="twitter:site"][content="' + twitter_handle + '"]',
                                visible: false

      expect(page).to have_css 'meta[name="twitter:title"][content="' + meta_title + '"]',
                                visible: false

      expect(page).to have_css 'meta[name="twitter:description"]'\
                               '[content="' + meta_description + '"]', visible: false

      expect(page).to have_css 'meta[name="twitter:image"]'\
                               '[content="http://www.example.com/social_media_twitter.jpg"]',
                                visible: false

      expect(page).to have_css 'meta[property="og:title"][content="' + meta_title + '"]',
                                visible: false

      expect(page).to have_css 'meta[property="article:publisher"][content="' + url + '"]',
                                visible: false

      expect(page).to have_css 'meta[property="article:author"]'\
                               '[content="https://www.facebook.com/'+ facebook_handle + '"]',
                                visible: false

      expect(page).to have_css 'meta[property="og:url"][content="http://www.example.com/"]',
                                visible: false

      expect(page).to have_css 'meta[property="og:image"]'\
                               '[content="http://www.example.com/social_media.jpg"]', visible: false

      expect(page).to have_css 'meta[property="og:site_name"][content="' + org_name + '"]',
                                visible: false

      expect(page).to have_css 'meta[property="og:description"]'\
                               '[content="' + meta_description + '"]', visible: false
    end
  end
end
