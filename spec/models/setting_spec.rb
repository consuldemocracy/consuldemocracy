require "rails_helper"

describe Setting do
  before do
    Setting["official_level_1_name"] = "Stormtrooper"
  end

  it "returns the overriden setting" do
    expect(Setting["official_level_1_name"]).to eq("Stormtrooper")
  end

  it "returns nil" do
    expect(Setting["undefined_key"]).to eq(nil)
  end

  it "persists a setting on the db" do
    expect(Setting.where(key: "official_level_1_name", value: "Stormtrooper")).to exist
  end

  describe "#prefix" do
    it "returns the prefix of its key" do
      expect(Setting.create!(key: "prefix.key_name").prefix).to eq "prefix"
    end

    it "returns the whole key for a non prefixed key" do
      expect(Setting.create!(key: "key_name").prefix).to eq "key_name"
    end
  end

  describe "#type" do
    it "returns the key prefix for 'process' settings" do
      process_setting = Setting.create!(key: "process.whatever")
      expect(process_setting.type).to eq "process"
    end

    it "returns the key prefix for 'feature' settings" do
      feature_setting = Setting.create!(key: "feature.whatever")
      expect(feature_setting.type).to eq "feature"
    end

    it "returns the key prefix for 'map' settings" do
      map_setting = Setting.create!(key: "map.whatever")
      expect(map_setting.type).to eq "map"
    end

    it "returns the key prefix for 'html' settings" do
      html_setting = Setting.create!(key: "html.whatever")
      expect(html_setting.type).to eq "html"
    end

    it "returns the key prefix for 'homepage' settings" do
      homepage_setting = Setting.create!(key: "homepage.whatever")
      expect(homepage_setting.type).to eq "homepage"
    end

    it "returns the key prefix for 'sdg' settings" do
      sdg_setting = Setting.create!(key: "sdg.whatever")

      expect(sdg_setting.type).to eq "sdg"
    end

    it "returns the key prefix for 'remote_census.general' settings" do
      remote_census_general_setting = Setting.create!(key: "remote_census.general.whatever")
      expect(remote_census_general_setting.type).to eq "remote_census.general"
    end

    it "returns the key prefix for 'remote_census_request' settings" do
      remote_census_request_setting = Setting.create!(key: "remote_census.request.whatever")
      expect(remote_census_request_setting.type).to eq "remote_census.request"
    end

    it "returns the key prefix for 'remote_census_response' settings" do
      remote_census_response_setting = Setting.create!(key: "remote_census.response.whatever")
      expect(remote_census_response_setting.type).to eq "remote_census.response"
    end

    it "returns 'configuration' for the rest of the settings" do
      configuration_setting = Setting.create!(key: "whatever")
      expect(configuration_setting.type).to eq "configuration"
    end
  end

  describe "#enabled?" do
    it "is true if value is present" do
      setting = Setting.create!(key: "feature.whatever", value: 1)
      expect(setting.enabled?).to eq true

      setting.value = "true"
      expect(setting.enabled?).to eq true

      setting.value = "whatever"
      expect(setting.enabled?).to eq true
    end

    it "is false if value is blank" do
      setting = Setting.create!(key: "feature.whatever")
      expect(setting.enabled?).to eq false

      setting.value = ""
      expect(setting.enabled?).to eq false
    end
  end

  describe "#content_type?" do
    it "returns true if the last part of the key is content_types" do
      expect(Setting.create!(key: "key_name.content_types").content_type?).to be true
    end

    it "returns false if the last part of the key is not content_types" do
      expect(Setting.create!(key: "key_name.whatever").content_type?).to be false
    end
  end

  describe "#content_type_group" do
    it "returns the group for content_types settings" do
      images =    Setting.create!(key: "update.images.content_types")
      documents = Setting.create!(key: "update.documents.content_types")

      expect(images.content_type_group).to    eq "images"
      expect(documents.content_type_group).to eq "documents"
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

  describe ".accepted_content_types_for" do
    it "returns the formats accepted according to the setting value" do
      Setting["uploads.images.content_types"] =    "image/jpeg image/gif"
      Setting["uploads.documents.content_types"] = "application/pdf application/msword"

      expect(Setting.accepted_content_types_for("images")).to    eq ["jpg", "gif"]
      expect(Setting.accepted_content_types_for("documents")).to eq ["pdf", "doc"]
    end

    it "returns empty array if setting does't exist" do
      Setting.remove("uploads.images.content_types")
      Setting.remove("uploads.documents.content_types")

      expect(Setting.accepted_content_types_for("images")).to    be_empty
      expect(Setting.accepted_content_types_for("documents")).to be_empty
    end
  end

  describe ".add_new_settings" do
    context "default settings with strings" do
      before do
        allow(Setting).to receive(:defaults).and_return({ stub: "stub" })
      end

      it "creates the setting if it doesn't exist" do
        expect(Setting.where(key: :stub)).to be_empty

        Setting.add_new_settings

        expect(Setting.where(key: :stub)).not_to be_empty
        expect(Setting.find_by(key: :stub).value).to eq "stub"
      end

      it "doesn't modify custom values" do
        Setting["stub"] = "custom"

        Setting.add_new_settings

        expect(Setting.find_by(key: :stub).value).to eq "custom"
      end

      it "doesn't modify custom nil values" do
        Setting["stub"] = nil

        Setting.add_new_settings

        expect(Setting.find_by(key: :stub).value).to be_nil
      end
    end

    context "nil default settings" do
      before do
        allow(Setting).to receive(:defaults).and_return({ stub: nil })
      end

      it "creates the setting if it doesn't exist" do
        expect(Setting.where(key: :stub)).to be_empty

        Setting.add_new_settings

        expect(Setting.where(key: :stub)).not_to be_empty
        expect(Setting.find_by(key: :stub).value).to be_nil
      end

      it "doesn't modify custom values" do
        Setting["stub"] = "custom"

        Setting.add_new_settings

        expect(Setting.find_by(key: :stub).value).to eq "custom"
      end
    end
  end

  describe ".force_presence_date_of_birth?" do
    it "return false when feature remote_census is not active" do
      Setting["feature.remote_census"] = false

      expect(Setting.force_presence_date_of_birth?).to eq false
    end

    it "return false when feature remote_census is active and date_of_birth is nil" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.date_of_birth"] = nil

      expect(Setting.force_presence_date_of_birth?).to eq false
    end

    it "return true when feature remote_census is active and date_of_birth is empty" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.date_of_birth"] = "some.value"

      expect(Setting.force_presence_date_of_birth?).to eq true
    end
  end

  describe ".force_presence_postal_code?" do
    it "return false when feature remote_census is not active" do
      Setting["feature.remote_census"] = false

      expect(Setting.force_presence_postal_code?).to eq false
    end

    it "return false when feature remote_census is active and postal_code is nil" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.postal_code"] = nil

      expect(Setting.force_presence_postal_code?).to eq false
    end

    it "return true when feature remote_census is active and postal_code is empty" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.postal_code"] = "some.value"

      expect(Setting.force_presence_postal_code?).to eq true
    end
  end
end
