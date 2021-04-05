section "Creating Settings" do
  Setting.reset_defaults

  {
    "facebook_handle": "GRPInnovaris",
    "feature.featured_proposals": "true",
    "feature.map": "true",
    "feature.sdg": "true",
    "instagram_handle": "grupoinnovaris",
    "mailer_from_address": "noreply@consul.dev",
    "mailer_from_name": "CONSUL",
    "meta_description": "Citizen participation tool for an open, "\
                        "transparent and democratic government",
    "meta_keywords": "citizen participation, open government",
    "meta_title": "CONSUL",
    "org_name": "INNCONSUL",
    "proposal_code_prefix": "INNCONSUL",
    "proposal_notification_minimum_interval_in_days": 0,
    "sdg.process.debates": "true",
    "sdg.process.proposals": "true",
    "sdg.process.polls": "true",
    "sdg.process.budgets": "true",
    "sdg.process.legislation": "true",
    "telegram_handle": "CONSUL",
    "twitter_handle": "grpinnovaris",
    "twitter_hashtag": "#consul_dev",
    "url": "http://localhost:3000",
    "votes_for_proposal_success": "100",
    "youtube_handle": "channel/UC_yuidFUJK7pKabqbj66k8g",
    "linkedin_handle": "innovaris-s.l."
  }.each do |name, value|
    Setting[name] = value
  end
end
