require "rails_helper"

describe Setting do
  before do
    Setting["official_level_1_name"] = "Stormtrooper"
  end

  it "returns the overriden setting" do
    expect(Setting["official_level_1_name"]).to eq("Stormtrooper")
  end

  it "returns nil" do
    expect(Setting["undefined_key"]).to be nil
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

  describe "#feature?" do
    it "returns true if the key prefix is process, feature or sdg" do
      expect(Setting.find_by!(key: "process.debates").feature?).to be true
      expect(Setting.find_by!(key: "feature.map").feature?).to be true
      expect(Setting.find_by!(key: "sdg.process.debates").feature?).to be true
      expect(Setting.find_by!(key: "uploads.documents.max_size").feature?).to be false
    end
  end

  describe "#enabled?" do
    it "is true if value is present" do
      setting = Setting.create!(key: "feature.whatever", value: 1)
      expect(setting.enabled?).to be true

      setting.value = "true"
      expect(setting.enabled?).to be true

      setting.value = "whatever"
      expect(setting.enabled?).to be true
    end

    it "is false if value is blank" do
      setting = Setting.create!(key: "feature.whatever")
      expect(setting.enabled?).to be false

      setting.value = ""
      expect(setting.enabled?).to be false
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
      Setting["uploads.images.content_types"] = "image/jpeg image/gif"
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

  describe ".default_org_name" do
    it "returns the main org name for the default tenant" do
      expect(Setting.default_org_name).to eq "CONSUL DEMOCRACY"
    end

    it "returns the tenant name for other tenants" do
      insert(:tenant, schema: "new", name: "New Institution")
      allow(Tenant).to receive(:current_schema).and_return("new")

      expect(Setting.default_org_name).to eq "New Institution"
    end
  end

  describe ".default_mailer_from_address" do
    before { allow(Tenant).to receive(:default_host).and_return("consuldemocracy.org") }

    it "uses the default host for the default tenant" do
      expect(Setting.default_mailer_from_address).to eq "noreply@consuldemocracy.org"
    end

    it "uses the tenant host for other tenants" do
      allow(Tenant).to receive(:current_schema).and_return("new")

      expect(Setting.default_mailer_from_address).to eq "noreply@new.consuldemocracy.org"
    end

    context "empty default host" do
      before { allow(Tenant).to receive(:default_host).and_return("") }

      it "uses consuldemocracy.dev as host" do
        expect(Setting.default_mailer_from_address).to eq "noreply@consuldemocracy.dev"
      end
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

        expect(Setting.find_by(key: :stub).value).to be nil
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
        expect(Setting.find_by(key: :stub).value).to be nil
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

      expect(Setting.force_presence_date_of_birth?).to be false
    end

    it "return false when feature remote_census is active and date_of_birth is nil" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.date_of_birth"] = nil

      expect(Setting.force_presence_date_of_birth?).to be false
    end

    it "return true when feature remote_census is active and date_of_birth is empty" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.date_of_birth"] = "some.value"

      expect(Setting.force_presence_date_of_birth?).to be true
    end
  end

  describe ".force_presence_postal_code?" do
    it "return false when feature remote_census is not active" do
      Setting["feature.remote_census"] = false

      expect(Setting.force_presence_postal_code?).to be false
    end

    it "return false when feature remote_census is active and postal_code is nil" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.postal_code"] = nil

      expect(Setting.force_presence_postal_code?).to be false
    end

    it "return true when feature remote_census is active and postal_code is empty" do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.postal_code"] = "some.value"

      expect(Setting.force_presence_postal_code?).to be true
    end
  end
end
