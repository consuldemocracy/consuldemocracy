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

  describe "#per_page_code_migration" do

    let :run_rake_task do
      Rake::Task["settings:per_page_code_migration"].reenable
      Rake.application.invoke_task "settings:per_page_code_migration"
    end

    context "Neither per_page_code_head or per_page_code Settings exist" do
      before do
        Setting.where(key: "per_page_code").first&.destroy
        Setting.where(key: "per_page_code_head").first&.destroy
        run_rake_task
      end

      it "has per_page_code_head setting present and no per_page_code" do
        expect(Setting.where(key: "per_page_code_head").count).to eq(1)
        expect(Setting["per_page_code_head"]).to eq(nil)
        expect(Setting.where(key: "per_page_code").count).to eq(0)
      end
    end

    context "Both per_page_code_head or per_page_code Settings exist" do
      before do
        Setting["per_page_code"] = "per_page_code"
        Setting["per_page_code_head"] = "per_page_code_head"
        run_rake_task
      end

      it "has per_page_code_head setting present and no per_page_code" do
        expect(Setting.where(key: "per_page_code_head").count).to eq(1)
        expect(Setting["per_page_code_head"]).to eq("per_page_code_head")
        expect(Setting.where(key: "per_page_code").count).to eq(0)
      end
    end

    context "per_page_code_head exists, but per_page_code does not" do
      before do
        Setting.where(key: "per_page_code").first&.destroy
        Setting["per_page_code_head"] = "per_page_code_head"
        run_rake_task
      end

      it "has per_page_code_head setting present and no per_page_code" do
        expect(Setting.where(key: "per_page_code_head").count).to eq(1)
        expect(Setting["per_page_code_head"]).to eq("per_page_code_head")
        expect(Setting.where(key: "per_page_code").count).to eq(0)
      end
    end

    context "per_page_code_head does not exist, but per_page_code does" do
      before do
        Setting["per_page_code"] = "per_page_code"
        Setting.where(key: "per_page_code_head").first&.destroy
        run_rake_task
      end

      it "has per_page_code_head setting present and no per_page_code" do
        expect(Setting.where(key: "per_page_code_head").count).to eq(1)
        expect(Setting["per_page_code_head"]).to eq("per_page_code")
        expect(Setting.where(key: "per_page_code").count).to eq(0)
      end
    end

  end

end
