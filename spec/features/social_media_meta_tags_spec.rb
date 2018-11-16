require 'rails_helper'

feature 'Social media meta tags' do

  context 'Setting social media meta tags' do

    let(:meta_keywords) { 'citizen, participation, open government' }
    let(:meta_title) { 'Register and support proposals to improve Madrid' }
    let(:meta_description) { "On the city council citizen participation website you "\
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

      expect(page).to have_meta "keywords", with: meta_keywords
      expect(page).to have_meta "twitter:site", with: twitter_handle
      expect(page).to have_meta "twitter:title", with: meta_title
      expect(page).to have_meta "twitter:description", with: meta_description
      expect(page).to have_meta "twitter:image",
                                 with:'http://www.example.com/social_media_twitter.jpg'

      expect(page).to have_property "og:title", with: meta_title
      expect(page).to have_property "article:publisher", with: url
      expect(page).to have_property "article:author", with: 'https://www.facebook.com/' +
                                                             facebook_handle
      expect(page).to have_property "og:url", with: 'http://www.example.com/'
      expect(page).to have_property "og:image", with: 'http://www.example.com/social_media.jpg'
      expect(page).to have_property "og:site_name", with: org_name
      expect(page).to have_property "og:description", with: meta_description
    end
  end
end
