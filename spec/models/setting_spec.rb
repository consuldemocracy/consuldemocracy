require "rails_helper"

describe Setting do
  before do
    described_class["official_level_1_name"] = "Stormtrooper"
  end

  it "returns the overriden setting" do
    expect(described_class["official_level_1_name"]).to eq("Stormtrooper")
  end

  it "shoulds return nil" do
    expect(described_class["undefined_key"]).to eq(nil)
  end

  it "persists a setting on the db" do
    expect(described_class.where(key: "official_level_1_name", value: "Stormtrooper")).to exist
  end

  describe "#type" do
    it "returns the key prefix for 'process' settings" do
      process_setting = Setting.create(key: "process.whatever")
      expect(process_setting.type).to eq "process"
    end

    it "returns the key prefix for 'feature' settings" do
      feature_setting = Setting.create(key: "feature.whatever")
      expect(feature_setting.type).to eq "feature"
    end

    it "returns the key prefix for 'map' settings" do
      map_setting = Setting.create(key: "map.whatever")
      expect(map_setting.type).to eq "map"
    end

    it "returns the key prefix for 'html' settings" do
      html_setting = Setting.create(key: "html.whatever")
      expect(html_setting.type).to eq "html"
    end

    it "returns the key prefix for 'homepage' settings" do
      homepage_setting = Setting.create(key: "homepage.whatever")
      expect(homepage_setting.type).to eq "homepage"
    end

    it "returns 'configuration' for the rest of the settings" do
      configuration_setting = Setting.create(key: "whatever")
      expect(configuration_setting.type).to eq "configuration"
    end
  end

  describe "#enabled?" do
    it "is true if value is present" do
      setting = described_class.create(key: "feature.whatever", value: 1)
      expect(setting.enabled?).to eq true

      setting.value = "true"
      expect(setting.enabled?).to eq true

      setting.value = "whatever"
      expect(setting.enabled?).to eq true
    end

    it "is false if value is blank" do
      setting = described_class.create(key: "feature.whatever")
      expect(setting.enabled?).to eq false

      setting.value = ""
      expect(setting.enabled?).to eq false
    end
  end

  describe ".rename_key" do
    it "renames the setting keeping the original value and deletes the old setting" do
      Setting["old_key"] = "old_value"

      Setting.rename_key from: "old_key", to: "new_key"

      expect(Setting.where(key: "new_key", value: "old_value")).to exist
      expect(Setting.where(key: "old_key")).not_to exist
    end

    it "initialize the setting with null value if old key doesn't exist" do
      expect(Setting.where(key: "old_key")).not_to exist

      Setting.rename_key from: "old_key", to: "new_key"

      expect(Setting.where(key: "new_key", value: nil)).to exist
      expect(Setting.where(key: "old_key")).not_to exist
    end

    it "does not change value if new key already exists, but deletes setting with old key" do
      Setting["new_key"] = "new_value"
      Setting["old_key"] = "old_value"

      Setting.rename_key from: "old_key", to: "new_key"

      expect(Setting["new_key"]).to eq "new_value"
      expect(Setting.where(key: "old_key")).not_to exist
    end
  end

  describe ".remove" do
    it "deletes the setting by given key" do
      expect(Setting.where(key: "official_level_1_name")).to exist

      Setting.remove("official_level_1_name")

      expect(Setting.where(key: "official_level_1_name")).not_to exist
    end

    it "does nothing if key doesn't exists" do
      all_settings = Setting.all

      Setting.remove("not_existing_key")

      expect(Setting.all).to eq all_settings
    end
  end
end
