section "Creating Settings" do
  Setting.reset_defaults

  {
    "facebook_handle": "CONSUL",
    "feature.featured_proposals": "true",
    "feature.map": "true",
    "feature.sdg": "true",
    "instagram_handle": "CONSUL",
    "mailer_from_address": "noreply@consul.dev",
    "mailer_from_name": "CONSUL",
    "meta_description": "Citizen participation tool for an open, "\
                        "transparent and democratic government",
    "meta_keywords": "citizen participation, open government",
    "meta_title": "CONSUL",
    "org_name": "CONSUL",
    "proposal_code_prefix": "MAD",
    "proposal_notification_minimum_interval_in_days": 0,
    "sdg.process.debates": "true",
    "sdg.process.proposals": "true",
    "sdg.process.polls": "true",
    "sdg.process.budgets": "true",
    "sdg.process.legislation": "true",
    "telegram_handle": "CONSUL",
    "twitter_handle": "@consul_dev",
    "twitter_hashtag": "#consul_dev",
    "url": "http://localhost:3000",
    "votes_for_proposal_success": "100",
    "youtube_handle": "CONSUL"
  }.each do |name, value|
    Setting[name] = value
  end
end
