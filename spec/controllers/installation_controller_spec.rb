require "rails_helper"

describe InstallationController, type: :request do

  describe "consul.json" do
    let(:test_feature_settings) do
      {
        "disabled_feature" => nil,
        "enabled_feature" => "t"
      }
    end

    let(:seeds_feature_settings) { Setting.where("key LIKE 'feature.%'") }

    before do
      @current_feature_settings = seeds_feature_settings.pluck(:key, :value).to_h
      seeds_feature_settings.destroy_all
      test_feature_settings.each do |feature_name, feature_value|
        Setting["feature.#{feature_name}"] = feature_value
      end
    end

    after do
      test_feature_settings.each_key do |feature_name|
        Setting.find_by(key: "feature.#{feature_name}").destroy
      end
      @current_feature_settings.each do |feature_name, feature_value|
        Setting[feature_name] = feature_value
      end
    end

    specify "with query string inside query params" do
      get "/consul.json"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["release"]).not_to be_empty
      expect(JSON.parse(response.body)["features"]).to eq(test_feature_settings)
    end
  end
end
