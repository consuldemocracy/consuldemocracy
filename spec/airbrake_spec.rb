require "rails_helper"

describe "Airbrake" do
  it "uses the same filtering rules that Consul Democracy" do
    expect(Airbrake::Config.instance.blocklist_keys).to eq Rails.application.config.filter_parameters
  end
end
