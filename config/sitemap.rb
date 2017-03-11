# not use compression
class SitemapGenerator::FileAdapter
  def gzip(stream, data); stream.write(data); stream.close end
end
SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(:sitemap, extension: '.xml')

# default host
SitemapGenerator::Sitemap.default_host = Setting["url"]

# sitemap generator
SitemapGenerator::Sitemap.create do
  pages = Dir.entries(File.join(Rails.root,"app","views","pages"))
  pages.each do |page|
    page_name = page.split(".").first
    add page_name if page_name.present?
  end

  add "help_translate"

  add debates_path, priority: 0.7, changefreq: "daily"
  Debate.find_each do |debate|
    add debate_path(debate), lastmod: debate.updated_at
  end

  add proposals_path, priority: 0.7, changefreq: "daily"
  Proposal.find_each do |proposal|
    add proposal_path(proposal), lastmod: proposal.updated_at
  end

  add proposal_ballots_path

  add spending_proposals_path, priority: 0.7, changefreq: "daily"
  SpendingProposal.find_each do |spending_proposal|
    add spending_proposal_path(spending_proposal), lastmod: spending_proposal.updated_at
  end
end
