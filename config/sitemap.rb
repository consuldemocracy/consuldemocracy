# not use compression
class SitemapGenerator::FileAdapter
  def gzip(stream, data); stream.write(data); stream.close end
end
SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(:sitemap, extension: '.xml')

# default host
SitemapGenerator::Sitemap.default_host = Setting["url"]

# sitemap generator
SitemapGenerator::Sitemap.create do
  pages = ["accessibility",
           "census_terms",
           "conditions",
           "general_terms",
           "privacy"]
  pages.each do |page|
    add page_path(id: page)
  end

  add more_info_path
  add how_to_use_path
  add faq_path

  add debates_path, priority: 0.7, changefreq: "daily"
  Debate.find_each do |debate|
    add debate_path(debate), lastmod: debate.updated_at
  end

  add proposals_path, priority: 0.7, changefreq: "daily"
  Proposal.find_each do |proposal|
    add proposal_path(proposal), lastmod: proposal.updated_at
  end

  add spending_proposals_path, priority: 0.7, changefreq: "daily"
  SpendingProposal.find_each do |spending_proposal|
    add spending_proposal_path(spending_proposal), lastmod: spending_proposal.updated_at
  end

  add budgets_path, priority: 0.7, changefreq: "daily"
  Budget.find_each do |budget|
    add budget_path(budget), lastmod: budget.updated_at
  end

  add polls_path, priority: 0.7, changefreq: "daily"
  Poll.find_each do |poll|
    add poll_path(poll), lastmod: poll.starts_at
  end
end
