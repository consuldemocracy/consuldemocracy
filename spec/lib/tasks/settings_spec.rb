require "rails_helper"

describe Setting do

  context "Remove deprecated settings" do

    let :run_remove_deprecated_settings_task do
      Rake::Task["settings:remove_deprecated_settings"].reenable
      Rake.application.invoke_task "settings:remove_deprecated_settings"
    end

    before do
      Setting.create(key: "place_name", value: "City")
      Setting.create(key: "banner-style.banner-style-one", value: "Style one")
      Setting.create(key: "banner-style.banner-style-two", value: "Style two")
      Setting.create(key: "banner-style.banner-style-three", value: "Style three")
      Setting.create(key: "banner-img.banner-img-one", value: "Image 1")
      Setting.create(key: "banner-img.banner-img-two", value: "Image 2")
      Setting.create(key: "banner-img.banner-img-three", value: "Image 3")
      Setting.create(key: "verification_offices_url", value: "http://offices.url")
      Setting.create(key: "not_deprecated", value: "Setting not deprecated")
      run_remove_deprecated_settings_task
    end

    it "Rake only removes deprecated settings" do
      expect(Setting.where(key: "place_name").count).to eq(0)
      expect(Setting.where(key: "banner-style.banner-style-one").count).to eq(0)
      expect(Setting.where(key: "banner-style.banner-style-two").count).to eq(0)
      expect(Setting.where(key: "banner-style.banner-style-three").count).to eq(0)
      expect(Setting.where(key: "banner-img.banner-img-one").count).to eq(0)
      expect(Setting.where(key: "banner-img.banner-img-two").count).to eq(0)
      expect(Setting.where(key: "banner-img.banner-img-three").count).to eq(0)
      expect(Setting.where(key: "verification_offices_url").count).to eq(0)
      expect(Setting.where(key: "not_deprecated").count).to eq(1)
    end
  end

  describe "#rename_setting_keys" do

    let :run_rake_task do
      Rake::Task["settings:rename_setting_keys"].reenable
      Rake.application.invoke_task "settings:rename_setting_keys"
    end

    let :old_keys do
      %w[map_latitude map_longitude map_zoom feature.debates feature.proposals feature.polls
         feature.budgets feature.legislation per_page_code_head per_page_code_body
         feature.homepage.widgets.feeds.proposals feature.homepage.widgets.feeds.debates
         feature.homepage.widgets.feeds.processes]
    end

    let :new_keys do
      %w[map.latitude map.longitude map.zoom process.debates process.proposals process.polls
         process.budgets process.legislation html.per_page_code_head html.per_page_code_body
         homepage.widgets.feeds.proposals homepage.widgets.feeds.debates
         homepage.widgets.feeds.processes]
    end

    context "with existing old settings" do
      it "rename all settings keys keeping the same value" do
        Setting.destroy_all
        old_keys.each { |old_key| Setting[old_key] = "old value" }

        run_rake_task

        new_keys.each do |new_key|
          expect(Setting[new_key]).to eq "old value"
        end

        old_keys.each do |old_key|
          expect(Setting.where(key: old_key)).not_to exist
        end
      end
    end

    context "without existing old settings" do
      it "initializes all settings with null value" do
        Setting.destroy_all

        run_rake_task

        new_keys.each do |new_key|
          expect(Setting[new_key]).to eq nil
        end

        old_keys.each do |old_key|
          expect(Setting.where(key: old_key)).not_to exist
        end
      end
    end

    context "with already existing new settings" do
      it "does not change the value of the new settings even if the old setting exist" do
        Setting.destroy_all
        old_keys.each { |old_key| Setting[old_key] = "old value" }
        new_keys.each { |new_key| Setting[new_key] = "new value" }

        run_rake_task

        new_keys.each do |new_key|
          expect(Setting[new_key]).to eq "new value"
        end

        old_keys.each do |old_key|
          expect(Setting.where(key: old_key)).not_to exist
        end
      end
    end

  end

end
