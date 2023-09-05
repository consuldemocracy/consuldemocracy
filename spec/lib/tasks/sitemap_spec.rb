require "rails_helper"

describe "rake sitemap:create", type: :system do
  let(:file) { Rails.root.join("public", "sitemap.xml") }
  let(:run_rake_task) { Rake.application.invoke_task("sitemap:create") }

  before do
    FileUtils.rm_f(file)
    Rake::Task["sitemap:create"].reenable
  end

  describe "when processes are enabled" do
    before { run_rake_task }

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

      run_rake_task
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

  it "generates a sitemap for every tenant" do
    allow(Tenant).to receive(:default_url_options).and_return({ host: "consul.dev" })
    FileUtils.rm_f(Dir.glob(Rails.root.join("public", "tenants", "*", "sitemap.xml")))

    create(:tenant, schema: "debates")
    create(:tenant, schema: "proposals")

    Setting["process.budgets"] = true
    Setting["process.debates"] = false
    Setting["process.proposals"] = false

    Tenant.switch("debates") do
      Setting["process.debates"] = true
      Setting["process.budgets"] = false
      Setting["process.proposals"] = false
    end

    Tenant.switch("proposals") do
      Setting["process.proposals"] = true
      Setting["process.budgets"] = false
      Setting["process.debates"] = false
    end

    run_rake_task

    public_sitemap = File.read(file)
    debates_sitemap = File.read(Rails.root.join("public", "tenants", "debates", "sitemap.xml"))
    proposals_sitemap = File.read(Rails.root.join("public", "tenants", "proposals", "sitemap.xml"))

    expect(public_sitemap).to have_content budgets_url(host: "consul.dev")
    expect(public_sitemap).not_to have_content debates_path
    expect(public_sitemap).not_to have_content proposals_path

    expect(debates_sitemap).to have_content debates_url(host: "debates.consul.dev")
    expect(debates_sitemap).not_to have_content budgets_path
    expect(debates_sitemap).not_to have_content proposals_path

    expect(proposals_sitemap).to have_content proposals_url(host: "proposals.consul.dev")
    expect(proposals_sitemap).not_to have_content budgets_path
    expect(proposals_sitemap).not_to have_content debates_path
  end
end
