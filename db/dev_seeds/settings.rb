section "Creating Settings" do
  Setting.reset_defaults

  Setting.create(key: "official_level_1_name",
                 value: I18n.t("seeds.settings.official_level_1_name"))
  Setting.create(key: "official_level_2_name",
                 value: I18n.t("seeds.settings.official_level_2_name"))
  Setting.create(key: "official_level_3_name",
                 value: I18n.t("seeds.settings.official_level_3_name"))
  Setting.create(key: "official_level_4_name",
                 value: I18n.t("seeds.settings.official_level_4_name"))
  Setting.create(key: "official_level_5_name",
                 value: I18n.t("seeds.settings.official_level_5_name"))
  Setting.create(key: "proposal_code_prefix", value: "MAD")
  Setting.create(key: "votes_for_proposal_success", value: "100")

  Setting.create(key: "twitter_handle", value: "@consul_dev")
  Setting.create(key: "twitter_hashtag", value: "#consul_dev")
  Setting.create(key: "facebook_handle", value: "CONSUL")
  Setting.create(key: "youtube_handle", value: "CONSUL")
  Setting.create(key: "telegram_handle", value: "CONSUL")
  Setting.create(key: "instagram_handle", value: "CONSUL")
  Setting.create(key: "url", value: "http://localhost:3000")
  Setting.create(key: "org_name", value: "CONSUL")

  Setting.create(key: "feature.featured_proposals", value: "true")

  Setting.create(key: "feature.map", value: "true")

  Setting.create(key: "mailer_from_name", value: "CONSUL")
  Setting.create(key: "mailer_from_address", value: "noreply@consul.dev")
  Setting.create(key: "meta_title", value: "CONSUL")
  Setting.create(key: "meta_description", value: "Citizen participation tool for an open, "\
                                                 "transparent and democratic government")
  Setting.create(key: "meta_keywords", value: "citizen participation, open government")
  Setting.create(key: "proposal_notification_minimum_interval_in_days", value: 0)
end
