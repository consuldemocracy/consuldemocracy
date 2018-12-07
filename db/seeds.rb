# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: "admin", email: "admin@consul.dev", password: "12345678",
                       password_confirmation: "12345678", confirmed_at: Time.current,
                       terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting["official_level_1_name"] = "Cargo oficial 1"
Setting["official_level_2_name"] = "Cargo oficial 2"
Setting["official_level_3_name"] = "Cargo oficial 3"
Setting["official_level_4_name"] = "Cargo oficial 4"
Setting["official_level_5_name"] = "Cargo oficial 5"

Setting["max_ratio_anon_votes_on_debates"] = 50

Setting["max_votes_for_debate_edit"] = 1000

Setting["max_votes_for_proposal_edit"] = 1000

Setting["comments_body_max_length"] = 1000

Setting["proposal_code_prefix"] = "CONSUL"

Setting["votes_for_proposal_success"] = 53726

Setting["months_to_archive_proposals"] = 12

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting["email_domain_for_officials"] = ""

# Code to be included at the top (inside <head>) of every page (useful for tracking)
Setting["html.per_page_code_head"] = ""

# Code to be included at the top (inside <body>) of every page
Setting["html.per_page_code_body"] = ""

Setting["twitter_handle"] = nil
Setting["twitter_hashtag"] = nil
Setting["facebook_handle"] = nil
Setting["youtube_handle"] = nil
Setting["telegram_handle"] = nil
Setting["instagram_handle"] = nil

Setting["url"] = "http://example.com" # Public-facing URL of the app.

# CONSUL installation's organization name
Setting["org_name"] = "CONSUL"

Setting["meta_title"] = nil
Setting["meta_description"] = nil
Setting["meta_keywords"] = nil

Setting["process.debates"] = true
Setting["process.proposals"] = true
Setting["process.polls"] = true
Setting["process.budgets"] = true
Setting["process.legislation"] = true

Setting["feature.featured_proposals"] = nil
Setting["feature.twitter_login"] = true
Setting["feature.facebook_login"] = true
Setting["feature.google_login"] = true
Setting["feature.public_stats"] = true
Setting["feature.signature_sheets"] = true
Setting["feature.user.recommendations"] = true
Setting["feature.user.recommendations_on_debates"] = true
Setting["feature.user.recommendations_on_proposals"] = true
Setting["feature.user.skip_verification"] = "true"
Setting["feature.community"] = true
Setting["feature.map"] = nil
Setting["feature.allow_images"] = true
Setting["feature.allow_attached_documents"] = true
Setting["feature.help_page"] = true

Setting["proposal_notification_minimum_interval_in_days"] = 3
Setting["direct_message_max_per_day"] = 3

Setting["mailer_from_name"] = "CONSUL"
Setting["mailer_from_address"] = "noreply@consul.dev"

Setting["min_age_to_participate"] = 16

Setting["featured_proposals_number"] = 3

Setting["map.latitude"] = 51.48
Setting["map.longitude"] = 0.0
Setting["map.zoom"] = 10

Setting["related_content_score_threshold"] = -0.3

Setting["homepage.widgets.feeds.proposals"] = true
Setting["homepage.widgets.feeds.debates"] = true
Setting["homepage.widgets.feeds.processes"] = true

Setting["hot_score_period_in_days"] = 31

WebSection.create(name: "homepage")
WebSection.create(name: "debates")
WebSection.create(name: "proposals")
WebSection.create(name: "budgets")
WebSection.create(name: "help_page")

Setting["proposals.successful_proposal_id"] = nil
Setting["proposals.poll_short_title"] = nil
Setting["proposals.poll_description"] = nil
Setting["proposals.poll_link"] = nil
Setting["proposals.email_short_title"] = nil
Setting["proposals.email_description"] = nil
Setting["proposals.poster_short_title"] = nil
Setting["proposals.poster_description"] = nil

Setting["dashboard.emails"] = nil

# Default custom pages
load Rails.root.join("db", "pages.rb")
