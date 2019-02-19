section "Creating Settings" do
  Setting["email_domain_for_officials"] = 'madrid.es'
  Setting.create(key: 'official_level_1_name', value: 'Empleados públicos')
  Setting.create(key: 'official_level_2_name', value: 'Organización Municipal')
  Setting.create(key: 'official_level_3_name', value: 'Directores generales')
  Setting.create(key: 'official_level_4_name', value: 'Concejales')
  Setting.create(key: 'official_level_5_name', value: 'Alcaldesa')
  Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')
  Setting.create(key: 'max_votes_for_debate_edit', value: '1000')
  Setting.create(key: 'max_votes_for_proposal_edit', value: '1000')
  Setting.create(key: 'proposal_code_prefix', value: 'MAD')
  Setting.create(key: 'votes_for_proposal_success', value: '100')
  Setting.create(key: 'months_to_archive_proposals', value: '12')
  Setting.create(key: 'comments_body_max_length', value: '1000')

  Setting.create(key: 'twitter_handle', value: '@decidemadrid')
  Setting.create(key: 'twitter_hashtag', value: '#decidemadrid')
  Setting.create(key: 'facebook_handle', value: 'decidemadrid')
  Setting.create(key: 'youtube_handle', value: 'decidemadrid')
  Setting.create(key: 'telegram_handle', value: 'decidemadrid')
  Setting.create(key: 'instagram_handle', value: 'decidemadrid')
  Setting.create(key: 'blog_url', value: 'https://diario.madrid.es/decidemadrid/')
  Setting.create(key: 'url', value: 'http://localhost:3000')
  Setting.create(key: 'org_name', value: 'Decide Madrid')

  Setting.create(key: 'feature.debates', value: "true")
  Setting.create(key: 'feature.proposals', value: "true")
  Setting.create(key: 'feature.featured_proposals', value: "true")
  Setting.create(key: 'feature.polls', value: "true")

  Setting.create(key: 'feature.spending_proposals', value: nil)
  Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: nil)
  Setting.create(key: 'feature.spending_proposal_features.phase1', value: nil)
  Setting.create(key: 'feature.spending_proposal_features.phase2', value: nil)
  Setting.create(key: 'feature.spending_proposal_features.phase3', value: "true")
  Setting.create(key: 'feature.spending_proposal_features.final_voting_allowed', value: "true")
  Setting.create(key: 'feature.spending_proposal_features.open_results_page', value: nil)

  Setting.create(key: 'feature.budgets', value: "true")
  Setting.create(key: 'feature.twitter_login', value: "true")
  Setting.create(key: 'feature.facebook_login', value: "true")
  Setting.create(key: 'feature.google_login', value: "true")
  Setting.create(key: 'feature.probe.plaza', value: 'true')
  Setting.create(key: 'feature.human_rights.accepting', value: 'true')
  Setting.create(key: 'feature.human_rights.voting', value: 'true')
  Setting.create(key: 'feature.human_rights.closed', value: 'true')
  Setting.create(key: 'feature.signature_sheets', value: "true")
  Setting.create(key: 'feature.legislation', value: "true")
  Setting.create(key: 'feature.user.recommendations', value: "true")
  Setting.create(key: 'feature.user.recommendations_on_debates', value: "true")
  Setting.create(key: 'feature.user.recommendations_on_proposals', value: "true")
  Setting.create(key: 'feature.community', value: "true")
  Setting.create(key: 'feature.map', value: "true")
  Setting.create(key: 'feature.allow_images', value: "true")
  Setting.create(key: 'feature.allow_attached_documents', value: "true")
  Setting.create(key: 'feature.public_stats', value: "true")
  Setting.create(key: 'feature.guides', value: true)
  Setting.create(key: 'feature.user.skip_verification', value: "true")
  Setting.create(key: 'feature.help_page', value: "true")

  Setting.create(key: 'per_page_code_head', value: "")
  Setting.create(key: 'per_page_code_body', value: "")
  Setting.create(key: 'comments_body_max_length', value: '1000')
  Setting.create(key: 'mailer_from_name', value: 'Decide Madrid')
  Setting.create(key: 'mailer_from_address', value: 'noreply@madrid.es')
  Setting.create(key: 'meta_description', value: 'Citizen Participation and Open Government Application')
  Setting.create(key: 'meta_title', value: 'Decide Madrid')
  Setting.create(key: 'meta_description', value: 'Citizen Participation & Open Gov Application')
  Setting.create(key: 'meta_keywords', value: 'citizen participation, open government')
  Setting.create(key: 'verification_offices_url', value: 'http://oficinas-atencion-ciudadano.url/')
  Setting.create(key: 'min_age_to_participate', value: '16')
  Setting.create(key: 'proposal_improvement_path', value: nil)
  Setting.create(key: 'map_latitude', value: 40.4332002)
  Setting.create(key: 'map_longitude', value: -3.7009591)
  Setting.create(key: 'map_zoom', value: 10)
  Setting.create(key: 'featured_proposals_number', value: 3)
  Setting.create(key: "proposal_notification_minimum_interval_in_days", value: 0)
  Setting.create(key: "direct_message_max_per_day", value: 3)

  Setting.create(key: 'related_content_score_threshold', value: -0.3)
  Setting.create(key: 'hot_score_period_in_days', value: 31)
  Setting.create(key: 'analytics_url', value: "")

  # piwik_tracking_code_head = "<!-- Piwik -->
  # <script type='text/javascript'>
  #   var _paq = _paq || [];
  #   _paq.push(['setDomains', ['*.decidedesa.madrid.es']]);
  #   _paq.push(['trackPageView']);
  #   _paq.push(['enableLinkTracking']);
  #   (function() {
  #     var u='//webanalytics01.madrid.es/';
  #     _paq.push(['setTrackerUrl', u+'piwik.php']);
  #     _paq.push(['setSiteId', '6']);
  #     var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
  #     g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  #   })();
  # </script>
  # <!-- End Piwik Code -->"
  # piwik_tracking_code_body = "<!-- Piwik -->
  # <noscript><p><img src='//webanalytics01.madrid.es/piwik.php?idsite=6' style='border:0;' alt=' /></p></noscript>
  # <!-- End Piwik Code -->"
  # Setting[:per_page_code_head] = piwik_tracking_code_head
  # Setting[:per_page_code_body] = piwik_tracking_code_body

  Setting['feature.homepage.widgets.feeds.proposals'] = true
  Setting['feature.homepage.widgets.feeds.debates'] = true
  Setting['feature.homepage.widgets.feeds.processes'] = true

end
