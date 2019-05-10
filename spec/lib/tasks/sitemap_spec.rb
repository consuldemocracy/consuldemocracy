require "rails_helper"

feature "rake sitemap:create" do
  before do
    @file ||= Rails.root.join("public", "sitemap.xml")

    # To avoid spec failures if file does not exist
    # Useful on CI environments or if file was created
    # previous to the specs (to ensure a clean state)
    File.delete(@file) if File.exist?(@file)

    Rake::Task["sitemap:create"].reenable
    Rake.application.invoke_task("sitemap:create")
  end

  it "generates a sitemap" do
    expect(@file).to exist
  end

  it "generates a valid sitemap" do
    sitemap = Nokogiri::XML(File.open(@file))
    expect(sitemap.errors).to be_empty
  end

  it "generates a sitemap with expected and valid URLs" do
    sitemap = File.read(@file)

    # Static pages
    expect(sitemap).to include(faq_path)
    expect(sitemap).to include(help_path)
    expect(sitemap).to include(how_to_use_path)

    # Dynamic URLs
    expect(sitemap).to include(polls_path)
    expect(sitemap).to include(budgets_path)
    expect(sitemap).to include(debates_path)
    expect(sitemap).to include(proposals_path)
    expect(sitemap).to include(legislation_processes_path)

    expect(sitemap).to have_content("0.7", count: 5)
    expect(sitemap).to have_content("daily", count: 5)
  end
end
