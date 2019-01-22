if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@consul.dev', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.current, terms_of_service: "1")
  admin.create_administrator
end

Setting["official_level_1_name"] = "Cargo oficial 1"
Setting["official_level_2_name"] = "Cargo oficial 2"
Setting["official_level_3_name"] = "Cargo oficial 3"
Setting["official_level_4_name"] = "Cargo oficial 4"
Setting["official_level_5_name"] = "Cargo oficial 5"
Setting["max_ratio_anon_votes_on_debates"] = 50
Setting["max_votes_for_debate_edit"] = 1000
Setting["max_votes_for_proposal_edit"] = 1000
Setting['comments_body_max_length'] = 1000
Setting["votes_for_proposal_success"] = 53726
Setting["months_to_archive_proposals"] = 12
Setting["email_domain_for_officials"] = ''
Setting['per_page_code_head'] = ''
Setting['per_page_code_body'] = ''
Setting['map_latitude'] = nil
Setting['map_longitude'] = nil
Setting['map_zoom'] = nil

Setting["twitter_handle"] = nil
Setting["twitter_hashtag"] = nil
Setting["facebook_handle"] = nil
Setting["youtube_handle"] = nil
Setting["telegram_handle"] = nil
Setting["instagram_handle"] = nil
Setting["blog_url"] = nil
Setting["transparency_url"] = nil
Setting["opendata_url"] = "/opendata"

Setting["meta_title"] = nil
Setting["meta_description"] = nil
Setting["meta_keywords"] = nil

Setting['feature.debates'] = true
Setting['feature.spending_proposals'] = true
Setting['feature.proposals'] = true
Setting['feature.featured_proposals'] = true
Setting['feature.spending_proposals'] = nil
Setting['feature.polls'] = true
Setting['feature.twitter_login'] = false
Setting['feature.facebook_login'] = false
Setting['feature.google_login'] = false
Setting['feature.public_stats'] = false
Setting['feature.budgets'] = true
Setting['feature.signature_sheets'] = true
Setting['feature.proposals'] = true
Setting['feature.legislation'] = true
Setting['feature.user.recommendations'] = true
Setting['feature.user.recommendations_on_debates'] = true
Setting['feature.user.recommendations_on_proposals'] = true
Setting['feature.community'] = true
Setting['feature.map'] = nil
Setting['feature.allow_images'] = true
Setting['feature.allow_attached_documents'] = true
Setting['feature.help_page'] = true
Setting['feature.spending_proposal_features.voting_allowed'] = nil
Setting['featured_proposals_number'] = 3
Setting["feature.user.skip_verification"] = 'true'
Setting['feature.homepage.widgets.feeds.proposals'] = true
Setting['feature.homepage.widgets.feeds.debates'] = true
Setting['feature.homepage.widgets.feeds.processes'] = true
Setting['feature.areas'] = true

Setting['proposal_notification_minimum_interval_in_days'] = 3
Setting['direct_message_max_per_day'] = 3
Setting['min_age_to_participate'] = 16
Setting['proposal_improvement_path'] = true
Setting['map_longitude'] = 0.0
Setting['map_zoom'] = 10
Setting['related_content_score_threshold'] = -0.3
Setting['hot_score_period_in_days'] = 31
Setting['verification_offices_url'] = 'http://oficinas-atencion-ciudadano.url/'

Setting['banner-style.banner-style-one']   = "Banner style 1"
Setting['banner-style.banner-style-two']   = "Banner style 2"
Setting['banner-style.banner-style-three'] = "Banner style 3"
Setting['banner-img.banner-img-one']   = "Banner image 1"
Setting['banner-img.banner-img-two']   = "Banner image 2"
Setting['banner-img.banner-img-three'] = "Banner image 3"

Setting["url"] = "https://decidim.castello.es"                if Setting["url"].nil?
Setting["org_name"] = "Ayuntamiento de Castellón de la Plana" if Setting["org_name"].nil?
Setting["place_name"] = "Castellón de la Plana"               if Setting["place_name"].nil?
Setting['mailer_from_name'] = 'Decidim Castelló'              if Setting["mailer_from_name"].nil?
Setting['mailer_from_address'] = 'noreply@castello.es'        if Setting["mailer_from_address"].nil?
Setting["proposal_code_prefix"] = 'CAS'                       if Setting["proposal_code_prefix"].nil?

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
