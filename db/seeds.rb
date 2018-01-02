# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@consul.dev', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.current, terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting["official_level_1_name"] = "Empleados públicos"
Setting["official_level_2_name"] = "Organización Municipal"
Setting["official_level_3_name"] = "Directores generales"
Setting["official_level_4_name"] = "Concejales"
Setting["official_level_5_name"] = "Alcaldesa"

# Max percentage of allowed anonymous votes on a debate
Setting["max_ratio_anon_votes_on_debates"] = 50

# Max votes where a debate is still editable
Setting["max_votes_for_debate_edit"] = 1000

# Max votes where a proposal is still editable
Setting["max_votes_for_proposal_edit"] = 1000

# Max length for comments
Setting['comments_body_max_length'] = 1000

# Prefix for the Proposal codes
Setting["proposal_code_prefix"] = 'CAS'

# Number of votes needed for proposal success
Setting["votes_for_proposal_success"] = 53726

# Months to archive proposals
Setting["months_to_archive_proposals"] = 12

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting["email_domain_for_officials"] = ''

# Code to be included at the top (inside <head>) of every page (useful for tracking)
Setting['per_page_code_head'] = ''

# Code to be included at the top (inside <body>) of every page
Setting['per_page_code_body'] = ''

# Social settings
Setting["twitter_handle"] = nil
Setting["twitter_hashtag"] = nil
Setting["facebook_handle"] = nil
Setting["youtube_handle"] = nil
Setting["telegram_handle"] = nil
Setting["instagram_handle"] = nil
Setting["blog_url"] = nil
Setting["transparency_url"] = nil
Setting["opendata_url"] = "/opendata"

# Public-facing URL of the app.
Setting["url"] = "https://decidim.castello.es"

# Consul installation's organization name
Setting["org_name"] = "Ayuntamiento de Castellón de la Plana"

# Consul installation place name (City, Country...)
Setting["place_name"] = "Castellón de la Plana"

# Meta tags for SEO
Setting["meta_title"] = nil
Setting["meta_description"] = nil
Setting["meta_keywords"] = nil

# Feature flags
Setting['feature.debates'] = true
Setting['feature.spending_proposals'] = true
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
Setting['feature.community'] = true
Setting['feature.map'] = nil
Setting['feature.allow_images'] = true

# Spending proposals feature flags
Setting['feature.spending_proposal_features.voting_allowed'] = nil

# Banner styles
Setting['banner-style.banner-style-one']   = "Banner style 1"
Setting['banner-style.banner-style-two']   = "Banner style 2"
Setting['banner-style.banner-style-three'] = "Banner style 3"

# Banner images
Setting['banner-img.banner-img-one']   = "Banner image 1"
Setting['banner-img.banner-img-two']   = "Banner image 2"
Setting['banner-img.banner-img-three'] = "Banner image 3"

# Proposal notifications
Setting['proposal_notification_minimum_interval_in_days'] = 3
Setting['direct_message_max_per_day'] = 3

# Email settings
Setting['mailer_from_name'] = 'Decidim Castelló'
Setting['mailer_from_address'] = 'noreply@castello.es'

# Verification settings
Setting['verification_offices_url'] = 'http://oficinas-atencion-ciudadano.url/'
Setting['min_age_to_participate'] = 16

Setting['proposal_improvement_path'] = nil
# ActsAsTaggableOn::Tag.create!(name:  "Asociaciones", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Cultura", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Deportes", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Derechos Sociales", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Economía", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Empleo", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Equidad", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Sostenibilidad", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Participación", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Movilidad", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Medios", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Salud", featured: true , kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Transparencia", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Seguridad y Emergencias", featured: true, kind: "category")
# ActsAsTaggableOn::Tag.create!(name:  "Medio Ambiente", featured: true, kind: "category")
#
# ['Urbanismo', 'Cultura', 'Deportes', 'Agricultura', 'Comercio y consumo', 'Juventud', 'Turismo',
#  'Igualdad', 'Gente Mayor', 'Bienestar Social', 'Seguridad ciudadana', 'Mercados', 'Fiestas',
#  'Servicios Públicos', 'Nuevas tecnologías', 'Atención y Participación ciudadana', 'Desarrollo Sostenible',
#  'Distrito Norte', 'Distrito Sur', 'Distrito Este', 'Distrito Oeste', 'Distrito Centro', 'Distrito Grao'].each do |c|
#
#   ActsAsTaggableOn::Tag.create!(name:  c, featured: true, kind: "category")
#
#  end

Setting['proposal_improvement_path'] = true
Setting['map_longitude'] = 0.0
Setting['map_zoom'] = 10

# Related content
Setting['related_content_score_threshold'] = -0.3
