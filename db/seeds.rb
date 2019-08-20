if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@consul.dev', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.current, terms_of_service: "1")
  admin.create_administrator
end

Setting["official_level_1_name"] = "Cargo oficial 1"          if Setting["official_level_1_name"].nil?
Setting["official_level_2_name"] = "Cargo oficial 2"          if Setting["official_level_2_name"].nil?
Setting["official_level_3_name"] = "Cargo oficial 3"          if Setting["official_level_3_name"].nil?
Setting["official_level_4_name"] = "Cargo oficial 4"          if Setting["official_level_4_name"].nil?
Setting["official_level_5_name"] = "Cargo oficial 5"          if Setting["official_level_5_name"].nil?
Setting["max_ratio_anon_votes_on_debates"] = 50               if Setting["max_ratio_anon_votes_on_debates"].nil?
Setting["max_votes_for_debate_edit"] = 1000                   if Setting["max_votes_for_debate_edit"].nil?
Setting["max_votes_for_proposal_edit"] = 1000                 if Setting["max_votes_for_proposal_edit"].nil?
Setting['comments_body_max_length'] = 1000                    if Setting["comments_body_max_length"].nil?
Setting["votes_for_proposal_success"] = 53726                 if Setting["votes_for_proposal_success"].nil?
Setting["months_to_archive_proposals"] = 12                   if Setting["months_to_archive_proposals"].nil?
Setting["email_domain_for_officials"] = ''                    if Setting["email_domain_for_officials"].nil?
Setting['per_page_code_head'] = ''                            if Setting["per_page_code_head"].nil?
Setting['per_page_code_body'] = ''                            if Setting["per_page_code_body"].nil?
Setting['map_latitude'] = false                               if Setting["map_latitude"].nil?
Setting['map_longitude'] = false                              if Setting["map_longitude"].nil?
Setting['map_zoom'] = false                                   if Setting["map_zoom"].nil?

Setting["twitter_handle"] = false                             if Setting["twitter_handle"].nil?
Setting["twitter_hashtag"] = false                            if Setting["twitter_hashtag"].nil?
Setting["facebook_handle"] = false                            if Setting["facebook_handle"].nil?
Setting["youtube_handle"] = false                             if Setting["youtube_handle"].nil?
Setting["telegram_handle"] = false                            if Setting["telegram_handle"].nil?
Setting["instagram_handle"] = false                           if Setting["instagram_handle"].nil?
Setting["blog_url"] = false                                   if Setting["blog_url"].nil?
Setting["transparency_url"] = false                           if Setting["transparency_url"].nil?
Setting["opendata_url"] = "/opendata"                         if Setting["opendata_url"].nil?

Setting["meta_title"] = false                                 if Setting["meta_title"].nil?
Setting["meta_description"] = false                           if Setting["meta_description"].nil?
Setting["meta_keywords"] = false                              if Setting["meta_keywords"].nil?

Setting['feature.spending_proposals'] = true                  if Setting["feature.spending_proposals"].nil?
Setting['feature.featured_proposals'] = true                  if Setting["feature.featured_proposals"].nil?
Setting['feature.twitter_login'] = false                      if Setting["feature.twitter_login"].nil?
Setting['feature.facebook_login'] = false                     if Setting["feature.facebook_login"].nil?
Setting['feature.google_login'] = false                       if Setting["feature.google_login"].nil?
Setting['feature.public_stats'] = false                       if Setting["feature.public_stats"].nil?
Setting['feature.budgets'] = true                             if Setting["feature.budgets"].nil?
Setting['feature.user.recommendations'] = true                if Setting["feature.user.recommendations"].nil?
Setting['feature.user.recommendations_on_debates'] = true     if Setting["feature.user.recommendations_on_debates"].nil?
Setting['feature.user.recommendations_on_proposals'] = true   if Setting["feature.user.recommendations_on_proposals"].nil?
Setting['feature.community'] = true                           if Setting["feature.community"].nil?
Setting['feature.map'] = false                                if Setting["feature.map"].nil?
Setting['feature.allow_images'] = true                        if Setting["feature.allow_images"].nil?
Setting['feature.allow_attached_documents'] = true            if Setting["feature.allow_attached_documents"].nil?
Setting['feature.help_page'] = true                           if Setting["feature.help_page"].nil?
Setting['feature.spending_proposal_features.voting_allowed'] = false  if Setting["feature.spending_proposal_features.voting_allowed"].nil?
Setting['featured_proposals_number'] = 3                      if Setting["featured_proposals_number"].nil?
Setting["feature.user.skip_verification"] = 'true'            if Setting["feature.user.skip_verification"].nil?
Setting['feature.homepage.widgets.feeds.proposals'] = true    if Setting["feature.homepage.widgets.feeds.proposals"].nil?
Setting['feature.homepage.widgets.feeds.debates'] = true      if Setting["feature.homepage.widgets.feeds.debates"].nil?
Setting['feature.homepage.widgets.feeds.processes'] = true    if Setting["feature.homepage.widgets.feeds.processes"].nil?
Setting['feature.areas'] = true                               if Setting["feature.areas"].nil?

Setting['proposal_notification_minimum_interval_in_days'] = 3 if Setting["proposal_notification_minimum_interval_in_days"].nil?
Setting['direct_message_max_per_day'] = 3                     if Setting["direct_message_max_per_day"].nil?
Setting['min_age_to_participate'] = 16                        if Setting["min_age_to_participate"].nil?
Setting['proposal_improvement_path'] = true                   if Setting["proposal_improvement_path"].nil?
Setting['map_longitude'] = 0.0                                if Setting["map_longitude"].nil?
Setting['map_zoom'] = 10                                      if Setting["map_zoom"].nil?
Setting['related_content_score_threshold'] = -0.3             if Setting["related_content_score_threshold"].nil?
Setting['hot_score_period_in_days'] = 31                      if Setting["hot_score_period_in_days"].nil?
Setting['verification_offices_url'] = 'http://oficinas-atencion-ciudadano.url/'   if Setting["verification_offices_url"].nil?

Setting['banner-style.banner-style-one']   = "Banner style 1" if Setting["banner-style.banner-style-one"].nil?
Setting['banner-style.banner-style-two']   = "Banner style 2" if Setting["banner-style.banner-style-two"].nil?
Setting['banner-style.banner-style-three'] = "Banner style 3" if Setting["banner-style.banner-style-three"].nil?
Setting['banner-img.banner-img-one']   = "Banner image 1"     if Setting["banner-img.banner-img-one"].nil?
Setting['banner-img.banner-img-two']   = "Banner image 2"     if Setting["banner-img.banner-img-two"].nil?
Setting['banner-img.banner-img-three'] = "Banner image 3"     if Setting["banner-img.banner-img-three"].nil?

Setting["url"] = "https://decidim.castello.es"                if Setting["url"].nil?
Setting["org_name"] = "Ayuntamiento de Castellón de la Plana" if Setting["org_name"].nil?
Setting["place_name"] = "Castellón de la Plana"               if Setting["place_name"].nil?
Setting['mailer_from_name'] = 'Decidim Castelló'              if Setting["mailer_from_name"].nil?
Setting['mailer_from_address'] = 'noreply@castello.es'        if Setting["mailer_from_address"].nil?
Setting["proposal_code_prefix"] = 'CAS'                       if Setting["proposal_code_prefix"].nil?
Setting['feature.debates'] = false                            if Setting["feature.debates"].nil?
Setting['feature.signature_sheets'] = false                   if Setting["feature.signature_sheets"].nil?
Setting['feature.proposals'] = false                          if Setting["feature.proposals"].nil?
Setting['feature.legislation'] = false                        if Setting["feature.legislation"].nil?
Setting['feature.polls'] = false                              if Setting["feature.polls"].nil?

WebSection.create(name: 'homepage')
WebSection.create(name: 'debates')
WebSection.create(name: 'proposals')
WebSection.create(name: 'budgets')
WebSection.create(name: 'help_page')

areas_es = { 'Urbanismo' =>  ['Mejora en calles, aceras,…',
                              'Mejoras limpia',
                              'Mejoras en el mobiliario',
                              'Mejoras en las zonas verdes',
                              'Ideas para hacer más accesible la ciudad',
                              'Mejorar en temas de iluminación y/o contaminación lumínica'],
  'Movilidad' => ['Ideas para hacer más fácil ir en bici por la ciudad',
                'Mejoras en la circulación',
                'Mejoras en el aparcamiento'],
  'Educación' => ['Mejoras en las instalaciones educativas',
                'Implantación de caminos escolares seguros'],
  'Salud pública' => ['Mejora en el trato con mascotas (espacios específicos, control de limpieza,…)',
                    'Medidas parra la reducción de la contaminación'],
  'Servicios municipales' => ['Mejorar la oferta de centros específicos para personas mayores, centros juveniles o infancia',
                            'Mejoras en el transporte',
                            'Mejorar las equipaciones deportivas'],
  'Cultura' => ['Mejoras en la oferta cultural y el ocio de la ciudad'],
  'Desarrollo y fomento del empleo' => ['Ideas para apoyar el comercio',
                                      'Ideas para mejorar en empleo',
                                      'Ideas para apoyar al tejido asociativo'],
  'Otros' => ['Has detectado algún problema en la ciudad y tienes una propuesta de solución que no entra en los apartados anteriores, cuéntanos!']
}
I18n.default_locale = :es
areas_es.each do |area, sub_areas|
  new_area = Area.find_or_create_by(name: area)
  areas_es[area].each do |sub_area_name|
    sub_area = SubArea.find_or_create_by(name: sub_area_name, area_id: new_area.id)
  end
end
