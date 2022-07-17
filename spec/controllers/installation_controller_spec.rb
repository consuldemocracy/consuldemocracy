require "rails_helper"

describe InstallationController, type: :request do
  describe "consul.json" do
    let(:test_process_settings) do
      {
        "disabled_process" => nil,
        "enabled_process" => "t"
      }
    end

    let(:seeds_process_settings) { Setting.where("key LIKE 'process.%'") }

    before do
      seeds_process_settings.destroy_all
      test_process_settings.each do |feature_name, feature_value|
        Setting["process.#{feature_name}"] = feature_value
      end
    end

    specify "with query string inside query params" do
      get "/consul.json"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["release"]).not_to be_empty
      expect(JSON.parse(response.body)["features"]).to eq(test_process_settings)
    end
  end
end
