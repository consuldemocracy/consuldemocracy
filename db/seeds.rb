# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: "admin", email: "admin@consul.dev", password: "12345678",
                       password_confirmation: "12345678", confirmed_at: Time.current,
                       terms_of_service: "1")
  admin.create_administrator
end

default_settings = {
  # Names for the moderation console, as a hint for moderators
  # to know better how to assign users with official positions
  "official_level_1_name": "Cargo oficial 1",
  "official_level_2_name": "Cargo oficial 2",
  "official_level_3_name": "Cargo oficial 3",
  "official_level_4_name": "Cargo oficial 4",
  "official_level_5_name": "Cargo oficial 5",
  "max_ratio_anon_votes_on_debates": 50,
  "max_votes_for_debate_edit": 1000,
  "max_votes_for_proposal_edit": 1000,
  "comments_body_max_length": 1000,
  "proposal_code_prefix": "CONSUL",
  "votes_for_proposal_success": 53726,
  "months_to_archive_proposals": 12,
  # Users with this email domain will automatically be marked as level 1 officials
  # Emails under the domain's subdomains will also be included
  "email_domain_for_officials": "",
  # Code to be included at the top (inside <head>) of every page (useful for tracking)
  "html.per_page_code_head": "",
  # Code to be included at the top (inside <body>) of every page
  "html.per_page_code_body": "",
  "twitter_handle": nil,
  "twitter_hashtag": nil,
  "facebook_handle": nil,
  "youtube_handle": nil,
  "telegram_handle": nil,
  "instagram_handle": nil,
  "url": "http://example.com", # Public-facing URL of the app.
  # CONSUL installation's organization name
  "org_name": "CONSUL",
  "meta_title": nil,
  "meta_description": nil,
  "meta_keywords": nil,
  "process.debates": true,
  "process.proposals": true,
  "process.polls": true,
  "process.budgets": true,
  "process.legislation": true,
  "feature.featured_proposals": nil,
  "feature.twitter_login": true,
  "feature.facebook_login": true,
  "feature.google_login": true,
  "feature.public_stats": true,
  "feature.signature_sheets": true,
  "feature.user.recommendations": true,
  "feature.user.recommendations_on_debates": true,
  "feature.user.recommendations_on_proposals": true,
  "feature.user.skip_verification": "true",
  "feature.community": true,
  "feature.map": nil,
  "feature.allow_images": true,
  "feature.allow_attached_documents": true,
  "feature.help_page": true,
  "proposal_notification_minimum_interval_in_days": 3,
  "direct_message_max_per_day": 3,
  "mailer_from_name": "CONSUL",
  "mailer_from_address": "noreply@consul.dev",
  "min_age_to_participate": 16,
  "featured_proposals_number": 3,
  "map.latitude": 51.48,
  "map.longitude": 0.0,
  "map.zoom": 10,
  "related_content_score_threshold": -0.3,
  "homepage.widgets.feeds.proposals": true,
  "homepage.widgets.feeds.debates": true,
  "homepage.widgets.feeds.processes": true,
  "hot_score_period_in_days": 31,
  "proposals.successful_proposal_id": nil,
  "proposals.poll_short_title": nil,
  "proposals.poll_description": nil,
  "proposals.poll_link": nil,
  "proposals.email_short_title": nil,
  "proposals.email_description": nil,
  "proposals.poster_short_title": nil,
  "proposals.poster_description": nil,
  "dashboard.emails": nil
}

default_settings.each do |name, value|
  Setting[name] = value
end

WebSection.create(name: "homepage")
WebSection.create(name: "debates")
WebSection.create(name: "proposals")
WebSection.create(name: "budgets")
WebSection.create(name: "help_page")

# Default custom pages
load Rails.root.join("db", "pages.rb")
