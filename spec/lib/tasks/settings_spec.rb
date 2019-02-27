require "rails_helper"

describe "Settings Rake" do

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
