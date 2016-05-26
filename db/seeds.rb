# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@madrid.es', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.now, terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting["official_level_1_name"] = "Empleados públicos"
Setting["official_level_2_name"] = "Organización Municipal"
Setting["official_level_3_name"] = "Directores generales"
Setting["official_level_4_name"] = "Concejales"
Setting["official_level_5_name"] = "Alcaldesa"

# Max percentage of allowed anonymous votes on a debate
Setting["max_ratio_anon_votes_on_debates"] = 50

# Max votes where a debate is still editable
Setting["max_votes_for_debate_edit"] = 1000

# Max votes where a proposal is still editable
Setting["max_votes_for_proposal_edit"] = 1000

# Max length for comments
Setting['comments_body_max_length'] = 1000

# Prefix for the Proposal codes
Setting["proposal_code_prefix"] = 'MAD'

# Number of votes needed for proposal success
Setting["votes_for_proposal_success"] = 53726

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting["email_domain_for_officials"] = ''

# Code to be included at the top (header) of every page (useful for tracking)
Setting['per_page_code'] =  ''

# Social settings
Setting["twitter_handle"] = "abriendomadrid"
Setting["twitter_hashtag"] = "#decidemadrid"
Setting["facebook_handle"] = "Abriendo-Madrid-1475577616080350"
Setting["youtube_handle"] = "channel/UCFmaChI9quIY7lwHplnacfg"
Setting["blog_url"] = "/blog"

# Public-facing URL of the app.
Setting["url"] = "https://decide.madrid.es"

# Consul installation's organization name
Setting["org_name"] = "Decide Madrid"

# Consul installation place name (City, Country...)
Setting["place_name"] = "Madrid"

# Feature flags
Setting['feature.debates'] = true
Setting['feature.spending_proposals'] = true
Setting['feature.twitter_login'] = true
Setting['feature.facebook_login'] = true
Setting['feature.google_login'] = true
Setting['feature.public_stats'] = true

# Spending proposals feature flags
Setting['feature.spending_proposal_features.phase1'] = true
Setting['feature.spending_proposal_features.phase2'] = nil
Setting['feature.spending_proposal_features.phase3'] = nil
Setting['feature.spending_proposal_features.voting_allowed'] = true
Setting['feature.spending_proposal_features.final_voting_allowed'] = true
Setting['feature.spending_proposal_features.valuation_allowed'] = nil

# Banner styles
Setting['banner-style.banner-style-one']   = "Banner style 1"
Setting['banner-style.banner-style-two']   = "Banner style 2"
Setting['banner-style.banner-style-three'] = "Banner style 3"

# Banner images
Setting['banner-img.banner-img-one']   = "Banner image 1"
Setting['banner-img.banner-img-two']   = "Banner image 2"
Setting['banner-img.banner-img-three'] = "Banner image 3"
