section "Creating custom Settings" do
  Setting['org_name'] = 'Conseil Départemental des Jeunes'
  Setting['place_name'] = 'Aude'
  Setting["url"] = "http://cdj.aude.fr/"

  # Feature flags
  Setting['feature.articles'] = true
  Setting['feature.debates'] = true
  Setting['feature.proposals'] = true
  Setting['feature.spending_proposals'] = nil
  Setting['feature.spending_proposal_features.voting_allowed'] = nil
  Setting['feature.polls'] = true
  Setting['feature.twitter_login'] = true
  Setting['feature.facebook_login'] = true
  Setting['feature.google_login'] = true
  Setting['feature.public_stats'] = true
  Setting['feature.budgets'] = nil
  Setting['feature.signature_sheets'] = true
  Setting['feature.legislation'] = nil
  Setting['feature.user.recommendations'] = true
  Setting['feature.community'] = true
  Setting['feature.map'] = true
  Setting['feature.allow_images'] = true
  Setting['feature.guides'] = nil

  # SEO
  Setting['meta_title'] = "Conseil départemental des jeunes de l'Aude"
  Setting['meta_description'] = "Conseil départemental des jeunes de l'Aude"
  Setting['meta_keywords'] = 'participation, jeunes, citoyenneté'

  # Settings extraient de l ancienne BDD
  Setting['min_age_to_participate'] = '16'
  Setting['max_age_to_participate'] = '25'
  Setting['proposal_code_prefix'] = 'CDJ'
  Setting['votes_for_proposal_success'] = '30'
  Setting['votes_for_debate_success'] = '30'

  #Setting.create(key: 'official_level_1_name',
  #               value: I18n.t('seeds.settings.official_level_1_name'))
  #Setting.create(key: 'official_level_2_name',
  #               value: I18n.t('seeds.settings.official_level_2_name'))
  #Setting.create(key: 'official_level_3_name',
  #               value: I18n.t('seeds.settings.official_level_3_name'))
  #Setting.create(key: 'official_level_4_name',
  #               value: I18n.t('seeds.settings.official_level_4_name'))
  #Setting.create(key: 'official_level_5_name',
  #               value: I18n.t('seeds.settings.official_level_5_name'))
  #Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')
  #Setting.create(key: 'max_votes_for_debate_edit', value: '1000')
  #Setting.create(key: 'max_votes_for_proposal_edit', value: '1000')
  #Setting.create(key: 'months_to_archive_proposals', value: '12')
  #Setting.create(key: 'comments_body_max_length', value: '1000')

  #Setting.create(key: 'twitter_handle', value: nil)
  #Setting.create(key: 'twitter_hashtag', value: nil)
  #Setting.create(key: 'facebook_handle', value: nil)
  #Setting.create(key: 'youtube_handle', value: nil)
  #Setting.create(key: 'telegram_handle', value: nil)
  #Setting.create(key: 'instagram_handle', value: nil)
  #Setting.create(key: 'blog_url', value: nil)
  #Setting.create(key: 'url', value: 'http://localhost:3000')

  #Setting.create(key: 'per_page_code_head', value: "")
  #Setting.create(key: 'per_page_code_body', value: "")
  #Setting.create(key: 'comments_body_max_length', value: '1000')
  #Setting.create(key: 'mailer_from_name', value: 'CONSUL')
  #Setting.create(key: 'mailer_from_address', value: 'noreply@consul.dev')
  #Setting.create(key: 'verification_offices_url', value: 'http://oficinas-atencion-ciudadano.url/')
  #Setting.create(key: 'min_age_to_participate', value: '16')
  #Setting.create(key: 'proposal_improvement_path', value: nil)
  #Setting.create(key: 'map_latitude', value: 40.41)
  #Setting.create(key: 'map_longitude', value: -3.7)
  #Setting.create(key: 'map_zoom', value: 10)
  #Setting.create(key: 'related_content_score_threshold', value: -0.3)
end
