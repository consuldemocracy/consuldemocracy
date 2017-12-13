require 'rails_helper'

describe InstallationController, type: :request do

  describe "consul.json" do
    let(:feature_settings) do
      {
        'debates' => nil,
        'spending_proposals' => 't',
        'polls' => nil,
        'twitter_login' => nil,
        'facebook_login' => nil,
        'google_login' => nil,
        'public_stats' => nil,
        'budgets' => nil,
        'signature_sheets' => nil,
        'legislation' => nil,
        'user.recommendations' => nil,
        'community' => nil,
        'map' => 't',
        'spending_proposal_features.voting_allowed' => 't',
        'allow_images' => 't'
      }
    end

    before do
      feature_settings.each { |feature_name, feature_value| Setting["feature.#{feature_name}"] = feature_value }
    end

    after do
      Setting['feature.debates'] = true
      Setting['feature.spending_proposals'] = nil
      Setting['feature.polls'] = true
      Setting['feature.twitter_login'] = true
      Setting['feature.facebook_login'] = true
      Setting['feature.google_login'] = true
      Setting['feature.public_stats'] = true
      Setting['feature.budgets'] = true
      Setting['feature.signature_sheets'] = true
      Setting['feature.legislation'] = true
      Setting['feature.user.recommendations'] = true
      Setting['feature.community'] = true
      Setting['feature.map'] = nil
      Setting['feature.spending_proposal_features.voting_allowed'] = nil
      Setting['feature.allow_images'] = true
    end

    specify "with query string inside query params" do
      get '/consul.json'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['release']).not_to be_empty
      expect(JSON.parse(response.body)['features']).to eq(feature_settings)
    end
  end
end
