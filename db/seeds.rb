# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(
    username: ENV['CONSUL_ADMIN_NAME'] || 'admin',
    email: ENV['CONSUL_ADMIN_EMAIL'] || 'admin@consul.dev',
    password: ENV['CONSUL_ADMIN_PASSWORD'] || '12345678',
    password_confirmation: ENV['CONSUL_ADMIN_PASSWORD'] || '12345678',
    confirmed_at: Time.current,
    terms_of_service: "1"
  )
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
if !Setting["official_level_1_name"]
  Setting["official_level_1_name"] = ENV['CONSUL_OFFICIAL_1'] || "Cargo oficial 1"
end
if !Setting["official_level_2_name"]
  Setting["official_level_2_name"] = ENV['CONSUL_OFFICIAL_2'] || "Cargo oficial 2"
end
if !Setting["official_level_3_name"]
  Setting["official_level_3_name"] = ENV['CONSUL_OFFICIAL_3'] || "Cargo oficial 3"
end
if !Setting["official_level_4_name"]
  Setting["official_level_4_name"] = ENV['CONSUL_OFFICIAL_4'] || "Cargo oficial 4"
end
if !Setting["official_level_5_name"]
  Setting["official_level_5_name"] = ENV['CONSUL_OFFICIAL_5'] || "Cargo oficial 5"
end


# Max percentage of allowed anonymous votes on a debate
if !Setting["max_ratio_anon_votes_on_debates"]
  Setting["max_ratio_anon_votes_on_debates"] = 50
end
# Max votes where a debate is still editable
if !Setting["max_votes_for_debate_edit"]
  Setting["max_votes_for_debate_edit"] = 1000
end
# Max votes where a proposal is still editable
if !Setting["max_votes_for_proposal_edit"]
  Setting["max_votes_for_proposal_edit"] = 1000
end

# Max length for comments
if !Setting["comments_body_max_length"]
  Setting['comments_body_max_length'] = 1000
end
# Prefix for the Proposal codes
if !Setting["proposal_code_prefix"]
  Setting["proposal_code_prefix"] = ENV['CONSUL_CODE_PREFIX'] || 'CONSUL'
end
# Number of votes needed for proposal success
if !Setting["votes_for_proposal_success"]
  Setting["votes_for_proposal_success"] = 53726
end
# Months to archive proposals
if !Setting["months_to_archive_proposals"]
  Setting["months_to_archive_proposals"] = 12
end
# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
if !Setting["email_domain_for_officials"]
  Setting["email_domain_for_officials"] = ''
end
# Code to be included at the top (inside <head>) of every page (useful for tracking)
if !Setting["per_page_code_head"]
  Setting['per_page_code_head'] = ''
end
# Code to be included at the top (inside <body>) of every page
if !Setting["per_page_code_body"]
  Setting['per_page_code_body'] = ''
end
# Social settings
if !Setting["twitter_handle"]
  Setting["twitter_handle"] = nil
end
if !Setting["twitter_hashtag"]
  Setting["twitter_hashtag"] = nil
end
if !Setting["facebook_handle"]
  Setting["facebook_handle"] = nil
end
if !Setting["youtube_handle"]
  Setting["youtube_handle"] = nil
end
if !Setting["telegram_handle"]
  Setting["telegram_handle"] = nil
end
if !Setting["instagram_handle"]
  Setting["instagram_handle"] = nil
end
if !Setting["blog_url"]
  Setting["blog_url"] = nil
end
if !Setting["transparency_url"]
  Setting["transparency_url"] = nil
end
if !Setting["opendata_url"]
  Setting["opendata_url"] = ENV['CONSUL_OPENDATA'] || "/opendata"
end
# Public-facing URL of the app.
if !Setting["url"]
  Setting["url"] = "http://example.com"
end
# CONSUL installation's organization name
if !Setting["org_name"]
  Setting["org_name"] = ENV['CONSUL_ORGANIZATION'] || "CONSUL"
end
# CONSUL installation place name (City, Country...)
if !Setting["place_name"]
  Setting["place_name"] = ENV['CONSUL_CITY'] || "CONSUL-land"
end
# Meta tags for SEO
if !Setting["meta_title"]
  Setting["meta_title"] = nil
end
if !Setting["meta_description"]
  Setting["meta_description"] = nil
end
if !Setting["meta_keywords"]
  Setting["meta_keywords"] = nil
end
# Feature flags
if !Setting["feature.debates"]
  Setting['feature.debates'] = true
end
if !Setting["feature.proposals"]
 Setting['feature.proposals'] = true
end
if !Setting["feature.featured_proposals"]
  Setting['feature.featured_proposals'] = true
end
if !Setting["feature.spending_proposals"]
  Setting['feature.spending_proposals'] = nil
end
if !Setting["feature.polls"]
  Setting['feature.polls'] = true
end
if !Setting["feature.twitter_login"]
  Setting['feature.twitter_login'] = true
end
if !Setting["feature.facebook_login"]
  Setting['feature.facebook_login'] = true
end
if !Setting["feature.google_login"]
  Setting['feature.google_login'] = true
end
if !Setting["feature.public_stats"]
  Setting['feature.public_stats'] = true
end
if !Setting["feature.budgets"]
  Setting['feature.budgets'] = true
end
if !Setting["feature.signature_sheets"]
  Setting['feature.signature_sheets'] = true
end
if !Setting["feature.legislation"]
  Setting['feature.legislation'] = true
end
if !Setting["feature.user.recommendations"]
  Setting['feature.user.recommendations'] = true
end
if !Setting["feature.user.recommendations_on_debates"]
  Setting['feature.user.recommendations_on_debates'] = true
end
if !Setting["feature.user.recommendations_on_proposals"]
  Setting['feature.user.recommendations_on_proposals'] = true
end
if !Setting["feature.cummunity"]
  Setting['feature.community'] = true
end
if !Setting["feature.map"]
  Setting['feature.map'] = nil
end
if !Setting["feature.allow_images"]
  Setting['feature.allow_images'] = true
end
if !Setting["feature.allow_attached_documents"]
  Setting['feature.allow_attached_documents'] = true
end
if !Setting["feature.help_page"]
  Setting['feature.help_page'] = true
end
# Spending proposals feature flags
if !Setting["feature.spending_proposal_features.voting_allowed"]
  Setting['feature.spending_proposal_features.voting_allowed'] = nil
end
# Banner styles
if !Setting["banner-style.banner-style-one"]
  Setting['banner-style.banner-style-one']   = "Banner style 1"
end
if !Setting["banner-style.banner-style-two"]
  Setting['banner-style.banner-style-two']   = "Banner style 2"
end
if !Setting["banner-style.banner-style-three"]
  Setting['banner-style.banner-style-three'] = "Banner style 3"
end
# Banner images
if !Setting["banner-img.banner-img-one"]
  Setting['banner-img.banner-img-one']   = "Banner image 1"
end
if !Setting["banner-img.banner-img-two"]
  Setting['banner-img.banner-img-two']   = "Banner image 2"
end
if !Setting["banner-img.banner-img-three"]
  Setting['banner-img.banner-img-three'] = "Banner image 3"
end
# Proposal notifications
if !Setting["proposal_notification_minimum_interval_in_days"]
  Setting['proposal_notification_minimum_interval_in_days'] = 3
end
if !Setting["direct_message_max_per_day"]
  Setting['direct_message_max_per_day'] = 3
end
# Email settings
if !Setting["mailer_from_name"]
  Setting['mailer_from_name'] = 'CONSUL'
end
if !Setting["mailer_from_address"]
  Setting['mailer_from_address'] = ENV['SMTP_FROM'] || 'noreply@consul.dev'
end
# Verification settings
if !Setting["verification_offices_url"]
  Setting['verification_offices_url'] = 'http://oficinas-atencion-ciudadano.url/'
end
if !Setting["min_age_to_participate"]
  Setting['min_age_to_participate'] = 16
end
# Featured proposals
if !Setting["featured_proposals_number"]
  Setting['featured_proposals_number'] = 3
end
# Proposal improvement url path ('/help/proposal-improvement')
if !Setting["proposal_improvement_path"]
  Setting['proposal_improvement_path'] = nil
end

# City map feature default configuration (Greenwich)
if !Setting["map_latitude"]
  Setting['map_latitude'] = 51.48
end
if !Setting["map_longitude"]
  Setting['map_longitude'] = 0.0
end
if !Setting["map_zoom"]
  Setting['map_zoom'] = 10
end

# Related content
if !Setting["related_content_score_threshold"]
  Setting['related_content_score_threshold'] = -0.3
end
if !Setting["feature.user.skip_verification"]
  Setting["feature.user.skip_verification"] = 'true'
end
if !Setting["feature.homepage.widgets.feeds.proposals"]
  Setting['feature.homepage.widgets.feeds.proposals'] = true
end
if !Setting["feature.homepage.widgets.feeds.debates"]
  Setting['feature.homepage.widgets.feeds.debates'] = true
end
if !Setting["feature.homepage.widgets.feeds.processes"]
  Setting['feature.homepage.widgets.feeds.processes'] = true
end

# Votes hot_score configuration
if !Setting["hot_score_period_in_days"]
  Setting['hot_score_period_in_days'] = 31
end
if !WebSection.exists?( :name => 'homepage')
WebSection.create(name: 'homepage')
end
if !WebSection.exists?(:name => 'debates')
  WebSection.create(name: 'debates')
end
if !WebSection.exists?(:name => 'proposals')
  WebSection.create(name: 'proposals')
end
if !WebSection.exists?(:name => 'budgets')
  WebSection.create(name: 'budgets')
end
if !WebSection.exists?(:name => 'help_page')
  WebSection.create(name: 'help_page')
end