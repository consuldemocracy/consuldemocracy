section "Creating Settings" do
    Setting.reset_defaults
  
    {
      "facebook_handle": "danesjenovdan",
      "feature.featured_proposals": "true",
      "instagram_handle": "danesjenovdan",
      "mailer_from_address": "postar@posta.danesjenovdan.si",
      "mailer_from_name": "CONSUL",
      "proposal_code_prefix": "MAD",
      "proposal_notification_minimum_interval_in_days": 0,
      "telegram_handle": "CONSUL",
      "twitter_handle": "@danesjenovdan",
      "twitter_hashtag": "#pp",
      "url": "http://localhost:3000",
      "votes_for_proposal_success": "100",
      "youtube_handle": "danesjenovdan",
  
      # added by MUKI
      "org_name": "Participativni proračun",
      "place_name": I18n.t("custom.meta.place_name"),
  
      "feature.debates": false,
      "feature.proposals": false,
      "feature.polls": false,
      "feature.spending_proposals": false,
      "feature.spending_proposal_features.voting_allowed": false,
      "feature.budgets": true,
      "feature.twitter_login": false,
      "feature.facebook_login": false,
      "feature.google_login": false,
      "feature.signature_sheets": false,
      "feature.legislation": false,
      "feature.user.recommendations": false,
      "feature.user.recommendations_on_debates": false,
      "feature.user.recommendations_on_proposals": false,
      "feature.community": false,
      "feature.map": true,
      "feature.allow_images": true,
      "feature.allow_attached_documents": true,
      "feature.public_stats": true,
      "feature.user.skip_verification": true,
      "feature.help_page": true,
  
      "meta_title": "Participatorni proračun",
      "meta_description": "",
      "meta_keywords": "citizen participation, open government",
      "verification_offices_url": "",
      "map.latitude": 46.06,
      "map.longitude": 14.39,
      "map.zoom": 10,
  
      "feature.homepage.widgets.feeds.proposals": false,
      "feature.homepage.widgets.feeds.debates": false,
      "feature.homepage.widgets.feeds.processes": false
    }.each do |name, value|
      Setting[name] = value
    end
  
    # // TODO: logo_header
  end
  