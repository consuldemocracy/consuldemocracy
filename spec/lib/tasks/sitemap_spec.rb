require "rails_helper"

describe "rake sitemap:create", type: :system do
  let(:file) { Rails.root.join("public", "sitemap.xml") }

  before do
    FileUtils.rm_f(file)
    Rake::Task["sitemap:create"].reenable
  end

  describe "when processes are enabled" do
    before { Rake.application.invoke_task("sitemap:create") }

    it "generates a valid sitemap" do
      sitemap = Nokogiri::XML(File.open(file))
      expect(sitemap.errors).to be_empty
    end

    it "generates a sitemap with expected and valid URLs" do
      sitemap = File.read(file)

      # Static pages
      expect(sitemap).to have_content(faq_path)
      expect(sitemap).to have_content(help_path)
      expect(sitemap).to have_content(how_to_use_path)

      # Dynamic URLs
      expect(sitemap).to have_content(polls_path)
      expect(sitemap).to have_content(budgets_path)
      expect(sitemap).to have_content(debates_path)
      expect(sitemap).to have_content(proposals_path)
      expect(sitemap).to have_content(legislation_processes_path)

      expect(sitemap).to have_content("0.7", count: 5)
      expect(sitemap).to have_content("daily", count: 5)
    end
  end

  describe "when processes are not enabled" do
    before do
      Setting["process.debates"] = nil
      Setting["process.proposals"] = nil
      Setting["process.budgets"] = nil
      Setting["process.polls"] = nil
      Setting["process.legislation"] = nil

      Rake.application.invoke_task("sitemap:create")
    end

    it "generates a valid sitemap" do
      sitemap = Nokogiri::XML(File.open(file))
      expect(sitemap.errors).to be_empty
    end

    it "generates a sitemap with expected and valid URLs" do
      sitemap = File.read(file)

      # Static pages
      expect(sitemap).to have_content(faq_path)
      expect(sitemap).to have_content(help_path)
      expect(sitemap).to have_content(how_to_use_path)

      # Dynamic URLs
      expect(sitemap).not_to have_content(polls_path)
      expect(sitemap).not_to have_content(budgets_path)
      expect(sitemap).not_to have_content(debates_path)
      expect(sitemap).not_to have_content(proposals_path)
      expect(sitemap).not_to have_content(legislation_processes_path)

      expect(sitemap).not_to have_content("0.7")
      expect(sitemap).not_to have_content("daily")
    end
  end
end
