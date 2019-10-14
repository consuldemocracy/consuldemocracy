# coding: utf-8
# Default admin user (change password after first deploy to a server!)


admin_password = Rails.application.secrets.consul_admin_default_pass
admin_email = Rails.application.secrets.consul_admin_default_email
raise "Not administrator password or email suplied, please configure it" unless admin_password|| admin_email

if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin_getafe', email: admin_email, password: admin_password, password_confirmation: admin_password, confirmed_at: Time.current, terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting["official_level_1_name"] = "Empleados públicos"
Setting["official_level_2_name"] = "Organización Municipal"
Setting["official_level_3_name"] = "Directores generales"
Setting["official_level_4_name"] = "Concejales"
Setting["official_level_5_name"] = "Alcaldesa"


Setting["support_email"] = "participa@getafe.es"
Setting["official_email"] = "presupuestos.participativos@ayto-getafe.org"
Setting["twitter_handle"] = "participagetafe"
Setting["facebook_handle"] = "ParticipaGetafe-1455484134478988"


# Max percentage of allowed anonymous votes on a debate
Setting["max_ratio_anon_votes_on_debates"] = 50

# Max votes where a debate is still editable
Setting["max_votes_for_debate_edit"] = 1000

# Max votes where a proposal is still editable
Setting["max_votes_for_proposal_edit"] = 1000

# Max length for comments
Setting['comments_body_max_length'] = 1000

# Prefix for the Proposal codes
Setting["proposal_code_prefix"] = 'GET'

# Number of votes needed for proposal success
Setting["votes_for_proposal_success"] = 53726

# Months to archive proposals
Setting["months_to_archive_proposals"] = 12

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting["email_domain_for_officials"] = ''

# Code to be included at the top (inside <head>) of every page (useful for tracking)
Setting['per_page_code_head'] =  ''

# Code to be included at the top (inside <body>) of every page
Setting['per_page_code_body'] =  ''

# Social settings
Setting["twitter_handle"] = 'http://twitter.com/participagetafe'
Setting["twitter_hashtag"] = 'participagetafe'
Setting["facebook_handle"] = 'https://www.facebook.com/ParticipaGetafe-1455484134478988/'
Setting["youtube_handle"] = nil
Setting["telegram_handle"] = nil
Setting["instagram_handle"] = nil
Setting["blog_url"] = nil
Setting["transparency_url"] = nil
Setting["opendata_url"] = "/opendata"

# Public-facing URL of the app.
Setting["url"] = "https://participa.getafe.es"

# Consul installation's organization name
Setting["org_name"] = "Participa Getafe"

# Consul installation place name (City, Country...)
Setting["place_name"] = "Getafe"

# Meta tags for SEO
Setting["meta_description"] = nil
Setting["meta_keywords"] = nil

# Feature flags
Setting['feature.debates'] = true
<<<<<<< HEAD
Setting['feature.spending_proposals'] = nil
Setting['feature.polls'] = true
Setting['feature.twitter_login'] = true
Setting['feature.facebook_login'] = true
Setting['feature.google_login'] = true
Setting['feature.public_stats'] = true
Setting['feature.budgets'] = true
Setting['feature.signature_sheets'] = true
Setting['feature.legislation'] = true
=======
Setting['feature.public_stats'] = true
Setting['feature.budgets'] = true
Setting['feature.signature_sheets'] = true
Setting['feature.spending_proposal_features.voting_allowed'] = nil
>>>>>>> development

# Spending proposals feature flags


Setting['feature.spending_proposals'] = true
Setting['feature.twitter_login'] = false
Setting['feature.facebook_login'] = false
Setting['feature.google_login'] = false
Setting['feature.public_stats'] = false

# Spending proposals feature flags
Setting['feature.spending_proposal_features.voting_allowed'] = false

# Banner styles
Setting['banner-style.banner-style-one']   = "Banner color primario"

# Banner images
Setting['banner-img.banner-img-one']   = "Imagen del Ayuntamiento"

# Proposal notifications
Setting['proposal_notification_minimum_interval_in_days'] = 3
Setting['direct_message_max_per_day'] = 3

# Email settings
Setting['mailer_from_name'] = 'Participa Getafe'
Setting['mailer_from_address'] = 'noreply@getafe.es'

# Verification settings
Setting['verification_offices_url'] = 'http://getafe.es/'
Setting['min_age_to_participate'] = 16

# Proposal improvement url path ('more-information/proposal-improvement')
Setting['proposal_improvement_path'] = nil

puts "Creating Geozones"
alhondiga = Geozone.create(name: "Alhóndiga", census_code: 'La Alhóndiga')
bercial = Geozone.create(name: "Bercial", census_code: 'El Bercial')
buenavista = Geozone.create(name: "Buenavista", census_code: 'Buenavista')
centro = Geozone.create(name: "Centro", census_code: 'Centro')
norte = Geozone.create(name: "Getafe Norte", census_code: 'Getafe-Norte')
cierva = Geozone.create(name: "Juan de la Cierva", census_code: 'Juan de la Cierva')
molinos = Geozone.create(name: "Los Molinos", census_code: 'Los Molinos')
margaritas = Geozone.create(name: "Margaritas", census_code: 'Las Margaritas')
perales = Geozone.create(name: "Perales del Río", census_code: 'Perales del Rio')
isidro = Geozone.create(name: "San Isidro", census_code: 'San Isidro')
sector3 = Geozone.create(name: "Sector III", census_code: 'Sector III')

puts "Creating Tags Categories"

# GET-40
ActsAsTaggableOn::Tag.create!(name:  "Centros cívicos", featured: true, kind: "category") #ok
ActsAsTaggableOn::Tag.create!(name:  "Cultura", featured: true, kind: "category") #ok
ActsAsTaggableOn::Tag.create!(name:  "Deportes", featured: true, kind: "category") #ok
ActsAsTaggableOn::Tag.create!(name:  "Servicios Sociales", featured: true, kind: "category") #ok
ActsAsTaggableOn::Tag.create!(name:  "Igualdad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Mayores", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Juventud", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Medio Ambiente", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Salud", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Seguridad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Formación", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Centros educativos", featured: true , kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Instalaciones deportivas", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Centros y asociaciones", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Viario público", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Alumbrado", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Mobiliario público", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Accesibilidad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Movilidad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Zonas infantiles", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Parques y jardines", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Áreas caninas", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Nuevas tecnologías", featured: true, kind: "category")




puts "Creating 2016 spending proposals"

# Cerrar las votaciones en la herramienta
Setting["feature.spending_proposal_features.voting_allowed"] = false
Setting["feature.spending_proposal_features.open_results_page"] = true

# Propuestas de gasto
# Margaritas
SpendingProposal.create(
  title: 'Remodelación de la confluencia en la c/velarde con c/sánchez morate',
  geozone: margaritas,
  description: '<strong>MAR-INV-01 Y OTROS</strong><p>El diseño final de la propuesta tendrá que analizarse en detalle, garantizando los espacios necesarios para
los peatones, el acceso de los vehículos de urgencia y el giro de los autobuses que pasan por ese punto.</p>',
  external_url: 'http://getafe.es/wp-content/uploads/prepar16_margaritas_inv_1.pdf',
  price: 226000,
  author_id: admin.id,
  feasible: true,
  phase: 'in_progress',
  spending_type: 'investment',
  terms_of_service: '1',
  created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Plan de acerado y pasos de peatones'  ,
    geozone: margaritas,
    phase: 'bidding',
    spending_type: 'investment',
    description: '<strong>MAR-INV-08</strong><p>Mejora de las aceras deterioradas e implementación de pasos de peatones</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_margaritas_inv_5.pdf',
    price: 300000-226000,
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Formación para jóvenes en el ámbito del ocio y tiempo libre, participación y asociacionismo',
    geozone: margaritas,
    phase: 'pre_bidding',
    spending_type: 'program',
    description: '<strong>MAR-PRO-04</strong><p>Jornadas formativas sobre el ámbito relacionado, educación en valores y habilidades sociales.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_margaritas_pro_2.pdf',
    price: 12000,
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

# Centro
SpendingProposal.create(
    title: 'Pinturas muro campaña concienciación Alzheimer',
    geozone: centro,
    description: '<strong>CEN-INV-08</strong> Ejecución de pinturas en Muro para concienciación Enfermedad Alzheimer.',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_centro_inv_4.pdf',
    price: 20000,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Arreglo calle Griñón',
    geozone: centro,
    description: '<strong>CEN-INV-11</strong> Arreglo de calzada y aceras',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_centro_inv_6.pdf',
    price: 92352.53,
    author_id: admin.id,
    phase: 'bidding',
    spending_type: 'investment',
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Reparación pavimento CEIP San José de Calasanz',
    geozone: centro,
    description: '<strong>CEN-INV-06</strong> Indican los proponentes que el pavimento no cumple requisitos de seguridad y debe ser subsanado.',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_centro_inv_3.pdf',
    price: 27416.15,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Acondicionamiento calle Madrid',
    geozone: centro,
    description: '<strong>CEN-INV-04</strong> Aumento de la iluminación, papeleras, bancos y elementos decorativos.',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_centro_inv_2.pdf',
    price: 27416.15,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
    geozone: centro,
    description: 'No encontrado',
    external_url: '',
    price: 12000,
    phase: 'pre_bidding',
    spending_type: 'program',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

# alhóndiga
SpendingProposal.create(
    title: 'Proyecto de reactivación y adecuación del Parque de La Alhóndiga',
    geozone: alhondiga,
    description: '<strong>ALH-INV-08</strong>
<p>Intervención integral en el Parque Alhóndiga para reactivación y mejora del uso y disfrute de los vecinos y vecinas, a saber:</p>
<ul>
<li>
Adecuación de sendas.
</li>
<li>
Ampliación de zona infantil con juegos inclusivos.
</li>
<li>
Zona deportiva Cross Fitt-Work Out
</li>

</ul>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_alhondiga_inv_6.pdf',
    price: 100000,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )


SpendingProposal.create(
    title: 'Arreglo y ensanche de las aceras en calle Fray Diego Ruiz',
    geozone: alhondiga,
    description: '<strong>ALH-INV-04</strong><p>Actuación de reparación del acerado de la Calle Fray Diego Ruiz y ensanchamiento en las dimensiones técnicamente posibles</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_alhondiga_inv_2.pdf',
    price: 130000,
    phase: 'in_progress',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Salida para la circulación desde calle Pato a calle Estudiantes',
    geozone: alhondiga,
    description: '<strong>ALH-INV-06</strong><p>Propuesta para aliviar los problemas de circulación en Calle Oca ya que a efectos prácticos la entrada y salida a la misma se hace por Avda. Reyes Católicos. Se trata de dar salida a la C/ Pato por C/Estudiantes.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_alhondiga_inv_4.pdf',
    price: 5000,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Instalación de columpios inclusivos',
    geozone: alhondiga,
    description: '<strong>ALH-INV-03</strong><p>Adaptación completa o parcial de las Zonas Infantiles del Barrio equipándolas con columpios inclusivos para infancia con movilidad reducida temporal o permanente y sin ninguna dificultad de movilidad. Dotar de pavimento en el que la movilidad de una silla de ruedas sea posible. Equipación adicional de las siguientes áreas:</p>
    <ul><li>Plaza Príncipe de Vergara</li><li>Plaza Rufino Castro</li><li>C/ Alondra con Paseo Alonso de Mendoza</li><li>Plaza Tirso de Molina</li><li>C/ Cóndor con Paseo Alonso de Mendoza</li><li> Plaza colindante con C/ Fray Diego Ruiz, Pintor Rosales y Alonso de Mendoza</li><li>Plaza Greco</li></ul>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_alhondiga_inv_4.pdf',
    price: 68486.45,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Atención psicológica gratuita grupal',
    geozone: alhondiga,
    description: '<strong>ALH-PRO-05</strong><p>Atención psicológica dirigida a niños, adolescentes y adultos para el aumento de competencias, aumento de recursos psicoemocionales potenciando una eficaz adaptación a las situaciones vitales</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_alhondiga_pro_4.pdf',
    price: 12000,
    phase: 'pre_bidding',
    spending_type: 'program',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

# Norte
SpendingProposal.create(
    title: 'Mejora de la accesibilidad de los pasos de peatones',
    geozone: norte,
    description: '<strong>GET-INV-05 Y OTROS</strong><p>Intervención integral para la eliminación de barreras arquitectónicas y mejora de la movilidad en pasos de peatones ubicados en el Barrio Getafe Norte, se manifiesta cómo enclaves prioritarios los situados en:</p>
    <ul><li>Avda. Los Ébanos con C/ Melocotón</li><li>Avda. Los Ébanos con Avda. Los Arces</li><li>Avda. Los Ébanos, 63 (entrada Colegio)</li><li>C/ de la Morera, hay dos pasos de peatones</li><li>C/ Montesori con Avda. Rigoberta Menchú</li><li>Avda. Los Arces (el del Ahorramás)</li></ul>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_gnorte_inv_2.pdf',
    price: 52318.36,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Arreglo acera avenida del Casar',
    geozone: norte,
    description: '<strong>GET-INV-07</strong><p>Intervención en el acerado de esta avenida que presenta irregularidades discontinuas en su trazado.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_gnorte_inv_3.pdf',
    price: 143861.78,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Adecuación de sendas en Parque Castilla-La Mancha (acceso a IES Menéndez Pelayo y barrio de Las Margaritas)',
    geozone: norte,
    description: '<strong>GET-INV-07</strong><p>Adecuación de pequeños caminos que "de hecho" existen por el uso, cuyo trazado discurre por el Parque Castilla La Mancha y que dan acceso al Instituto de Educación Secundaria Menéndez Pelayo y el Barrio Margaritas.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_gnorte_inv_8.pdf',
    price: 36606.55,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Renovación total de la acera C/ Juan Francés (Números pares)',
    geozone: norte,
    description: '<strong>GET-INV-09</strong><p>Actuación integral en la acera indicada. Subsanación del levantamiento del firme.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_gnorte_inv_4.pdf',
    price: 137389.09,
    phase: 'no_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: false,
    feasible_explanation: 'Excede presupuesto restante',
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )


SpendingProposal.create(
    title: 'Mejora del alumbrado de la calle Francisca Sauquillo',
    geozone: norte,
    description: '<strong>GET-INV-20</strong><p>Implementación y mejora del alumbrado en la Calle Francisca Sauquillo.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_gnorte_inv_9.pdf',
    price: 8853.47,
    phase: 'in_progress',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
geozone: norte,
description: '',
external_url: '',
price: 12000,
author_id: admin.id,
feasible: true,
phase: 'pre_bidding',
spending_type: 'program',
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

# PERALES
SpendingProposal.create(
title: 'Biblioteca',
geozone: perales,
description: '<strong>PR-INV-06</strong><p>Realización de las actuaciones necesarias para tener una Biblioteca con todas las prestaciones en el Centro Cívico del Barrio.</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_perales_inv_2.pdf',
price: 50000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Ampliación superficies deportivas anexas al campo de fútbol',
    geozone: perales,
    description: '<strong>PR-INV-09 Y OTROS</strong><p>Vecinos del Barrio de Perales del Río proponen la construcción de pistas deportivas anexas al Campo de Fútbol ya existente en este orden de prelación:</p>
    <ol><li>Skate Park</li><li>Pistas de Pádel</li><li>Pistas de Tenis</li></ol>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_perales_inv_4.pdf',
    price: 255354.01,
    phase: 'pre_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )


SpendingProposal.create(
    title: 'Gradas en el campo de fútbol de Perales',
    geozone: perales,
    description: '<strong>PR-INV-10 Y OTROS</strong><p>Implementar la instalación con gradas para espectadores. Se construiría en la "banda norte" del campo de
Fútbol.</p>',
    external_url: 'http://getafe.es/wp-content/uploads/prepar16_perales_inv_5.pdf',
    price: 105000,
    phase: 'no_bidding',
    spending_type: 'investment',
    author_id: admin.id,
    feasible: false,
    feasible_explanation: 'Excede presupuesto',
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
    title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
    geozone: perales,
    description: 'Sin especificar',
    external_url: nil,
    price: 12000,
    phase: 'pre_bidding',
    spending_type: 'program',
    author_id: admin.id,
    feasible: true,
    terms_of_service: '1',
    created_at: '2016-06-31', valuation_finished: true )

# Cierva
SpendingProposal.create(
title: 'Intervención parcial en el centro cívico Juan de la Cierva',
geozone: cierva,
description: '<strong>JC-INV-11</strong><p>Necesidad de ejecución de algunas tareas de reforma así como de dotación de equipamiento respetando la prelación de las necesidades</p>
<ul><li>Tarima en el gimnasio, reposición de telón en el escenario, instrumentos musicales,...</li><li>Reposición de carpintería y cristalería interior y exterior</li><li> Reparación de la grada. Pintura.</li></ul>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_jcierva_inv_7.pdf',
price: 290000,
phase: 'in_progress',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Acondicionamiento del acceso a la Parroquia Nuestra Señora del Cerro (calle Salamanca)',
geozone: cierva,
description: '<strong>JC-INV-06</strong><p>Facilitar el acceso a los locales parroquiales mediante la eliminación de las escaleras laterales y construcción de rampas</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_jcierva_inv_4.pdf',
price: 9586.37,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Programa de convivencia y educación de calle',
geozone: cierva,
description: '<strong>JC-PRO-05</strong><p>Se establecen dos líneas de trabajo:</p><ul><li>Reducción y gestión de los conflictos interpersonales, grupales y entre organizaciones presentes en el desarrollo de la convivencia de las actividades del Centro Cívico</li><li>Apoyo, identificación y trabajo de calle para las situaciones de bulling y acoso escolar en medio abierto de los centros IES Laguna de Joatzel e IES Satafi. Trabajo en los espacios externos del centro.</li></ul>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_jcierva_pro_1.pdf',
price: 12000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )


# Bercial
SpendingProposal.create(
title: 'Proyecto de rehabilitación y mejora del CEIP Seseña Benavente',
geozone: bercial,
description: '<strong>BER-INV-04 Y OTROS</strong><p>Se propone tres ejes fundamentales de actuación prioritaria: renovación integral de la fachada del Pabellón de Primaria, incorporación de baños a las aulas de Infantil y acondicionamiento de patios bajo criterios de calidad y seguridad</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_bercial_inv_3.pdf',
price: 304516.74,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
geozone: bercial,
description: 'Sin especificar',
external_url: nil,
price: 12000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )


# Isidro
SpendingProposal.create(
title: 'Recuperación y rehabilitación de ‘la Era’ (antiguas pistas deportivas y zona anexa)',
geozone: isidro,
description: '<strong>SI-INV-03 Y OTROS</strong><p>Rehabilitación de la zona para el ocio y esparcimiento de los vecinos del barrio, entre otros:</p>
<ul><li>Tratamiento (reparación o reposición) del pavimento.</li><li>Adecentamiento del distinto vallado.</li><li>Reparación de jardineras. Acondicionamiento de zona verde.</li><li> Dotar las pistas con juegos o equipamiento deportivo que la cubierta permita</li><li>Mobiliario urbano (bancos,..)</li><li>Kiosko Bar si fuera posible</li></ul>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_sanisidro_inv_2.pdf',
price: 63941.53,
phase: 'no_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Mejora de la accesibilidad al centro cívico San Isidro',
geozone: isidro,
description: '<strong>SI-INV-04 Y OTROS</strong><p>Exponen los proponentes que el acceso al Centro Cívico del barrio presenta condiciones mejorables. Relativas sobre todo a la puerta de acceso, el paso y la accesibilidad.</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_sanisidro_inv_1.pdf',
price: 250000,
phase: 'in_progress',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
geozone: isidro,
description: 'Sin especificar',
external_url: nil,
price: 12000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )


# molinos
SpendingProposal.create(
title: 'Ampliación zona deportiva EQ8',
geozone: molinos,
description: '<strong>LM-INV-05</strong><p>Se implementará con pista de patinaje, mesas de pin pon y ajedrez.</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_molinos_inv_4.pdf',
price: 220000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Barrera de árboles filtradores de partículas',
geozone: molinos,
description: '<strong>LM-INV-17</strong><p>Propuesta de plantación de hileras de elevada altura potencial en la región sur del barrio para que actúen de pantalla protectora (hacia C/ Gran Sultana)</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_molinos_inv_6.pdf',
price: 80000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
geozone: molinos,
description: 'Sin especificar',
external_url: nil,
price: 7000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Proceso participado',
geozone: molinos,
description: '<ol><li>Difusión</li><li>Actividades lúdicas</li><li>Talleres</li><li>Celebración</li></ol>',
external_url: nil,
price: 5000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )


#Buenavista
SpendingProposal.create(
title: 'Propuesta mixta',
geozone: buenavista,
description: '<strong></strong><p>Pista polideportiva en parcela ZV3, columpios aislados, techado de pérgolas, juegos pintados en pavimento y pavimentado de zona infantil.</p>',
external_url: 'http://getafe.es/areas-de-gobierno/area-social/participacion-ciudadana/actuaciones/presupuestos-participativos/proceso-de-votaciones-de-presupuestos-participativos-mayo-junio-2016/presupuestos-participativos-propuestas-aceptadas-buenavista/',
price: 220000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Arreglo de las gradas de madera',
geozone: buenavista,
description: '<strong>BUE-INV-31</strong><p>Arreglo de las gradas de madera de la plaza sita entre las calles María Lejárraga, José Giral, Santiago Casares y Federico Melchor. Acabado en madera tecnológica.</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_buenavista_inv_10.pdf',
price: 60000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Programación estable cultural en época primaveral y estival dirigido al público familiar',
geozone: buenavista,
description: 'Sin especificar',
external_url: nil,
price: 12000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )


# Sector III
SpendingProposal.create(
title: 'Adecuación de huerto urbano educativo y aula en la naturaleza',
geozone: sector3,
description: '<strong>S3-INV-10</strong><p>Se propone la creación de un invernadero y huerto educativo con implementación de talleres para divulgar conocimientos relativos al medio ambiente y el uso sostenible de recursos.</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_sector3_inv_2.pdf',
price: 125000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )


SpendingProposal.create(
title: 'Espacio de promoción y creación de artistas en CC Sector III',
geozone: sector3,
description: '<strong>S3-INV-07</strong><p>Se propone ligera ampliación del Centro Cívico Sector III por la "zona de tierras" próxima al Centro de poesía José Hierro para la creación de un espacio específico para trabajo de artistas locales.</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_sector3_inv_1.pdf',
price: 180000,
phase: 'pre_bidding',
spending_type: 'investment',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

SpendingProposal.create(
title: 'Ampliación de actividades para personas mayores de 65 años',
geozone: sector3,
description: '<strong>S3-PRO-01</strong><p>Apunta el proponente que dado que en el barrio esta población cada vez es más numerosa se pretende aumentar las actividades dirigidas a esta población: senderismo, tenis, pádel, salidas culturales,...</p>',
external_url: 'http://getafe.es/wp-content/uploads/prepar16_sector3_pro_1.pdf',
price: 12000,
phase: 'pre_bidding',
spending_type: 'program',
author_id: admin.id,
feasible: true,
terms_of_service: '1',
created_at: '2016-06-31', valuation_finished: true )

Commission.create(name: "Comisión Presupuestos Participativos Alhóndiga", place: "Centro Cívico Alhóndiga", address: "Plaza Rafael Pazos Pría, 1", geozone_id: alhondiga.id)
Commission.create(name: "Comisión Presupuestos Participativos Bercial", place: "Centro Cívico Bercial", address: "Avenida Buenos Aires, 2", geozone_id: bercial.id)
Commission.create(name: "Comisión Presupuestos Participativos Buenavista", place: "Centro Social Buenavista", address: "	Calle Ignacio Sánchez Coy, 2", geozone_id: buenavista.id)
Commission.create(name: "Comisión Presupuestos Participativos Centro", place: "Fábrica de Harinas", address: "	Calle Ramón y Cajal, 22", geozone_id: centro.id)
Commission.create(name: "Comisión Presupuestos Participativos Getafe Norte", place: "Centro Cívico Getafe Norte", address: "Avenida Rigoberta Menchú, 2", geozone_id: centro.id)
Commission.create(name: "Comisión Presupuestos Participativos Juan de la Cierva", place: "Centro Cívico Juan de la Cierva", address: "Plaza de Las Provincias, 1", geozone_id: cierva.id)
Commission.create(name: "Comisión Presupuestos Participativos Los Molinos", place: "Centro Social Los Molinos", address: "Avenida Rocinante,2", geozone_id: molinos.id)
Commission.create(name: "Comisión Centro Cívico Las Margaritas", place: "Centro Cívico Las Margaritas", address: "Avenida de las Ciudades, 11", geozone_id: margaritas.id)
Commission.create(name: "Comisión Centro Cívico Perales del Río", place: "Centro Cultural Julián Marías", address: "Calle Juan de Mairena, s/n", geozone_id: perales.id)
Commission.create(name: "Comisión Centro Cívico San Isidro", place: "Centro Cívico San Isidro", address: "Calle Leoncio Rojas, 18", geozone_id: isidro.id)
Commission.create(name: "Comisión Centro Cívico Sector III", place: "Centro Cívico Cerro Buenavista", address: "Buenavista	Avenida de las Arcas del Agua s/n", geozone_id: sector3.id)


Debate.create(title: 'Pregunta 1. Actividades', description: '¿Qué actividades consideras que se deberían llevar a cabo en tu barrio para mejorar la convivencia entre sus vecinos y vecinas?', author_id: admin.id, terms_of_service: '1' )
Debate.create(title: 'Pregunta 2. Opiniones', description: 'Las medidas que están contempladas en el Plan, ¿consideras que son necesarias en tu barrio? Opiniones y sugerencias al respecto.', author_id: admin.id, terms_of_service: '1' )
Debate.create(title: 'Pregunta 3. Valores', description: 'A tu juicio, ¿Cuál es el principal valor que aportan las diferentes diversidades (género, edad, procedencia, funcional, sexual, religiosa…) a la convivencia en la ciudad?', author_id: admin.id, terms_of_service: '1' )

# GET-57 Initialize Budget
budget = Budget.create(name: 'Presupuestos Participativos 2017', currency_symbol: '€', phase: 'accepting', description_accepting: '<p>Del <strong>23 de enero al 28 de febrero</strong>, toda persona empadronada en Getafe podrá crear propuestas para uno o varios barrios. Los 3.432.000 euros destinados a Inversiones y Programas se repartirán proporcionalmente en los 11 barrios.</p><p>Las propuestas se pueden hacer en esta web o de forma asistida en dependencias municipales de los barrios. A través de las Comisiones de Barrio se podrá debatir, pensar y trabajar juntos sobre las propuestas.</p>')
Geozone.order('name asc').each do |geozone|
  group = budget.groups.create(name: geozone.name, geozone_id:geozone.id)
  Budget::Heading.create(name: 'Propuestas de inversión', price: 300000, group_id: group.id)
  Budget::Heading.create(name: 'Propuestas de programas socio comunitarios', price: 12000, group_id: group.id)
end

Geozone.find_by_census_code('La Alhóndiga').update(html_map_coordinates: '157,62,110,134,122,198,127,147,142,105')
Geozone.find_by_census_code('El Bercial').update(html_map_coordinates: '162,28,138,41,125,56,106,68,95,105,112,123,160,54,169,36')
Geozone.find_by_census_code('Buenavista').update(html_map_coordinates: '81,125,40,177,41,187,39,196,48,198,78,184,83,156,85,137')
Geozone.find_by_census_code('Centro').update(html_map_coordinates: '145,112,139,125,134,138,129,155,131,164,137,168,144,169,154,168,161,160,162,141,157,131,163,126,155,119,152,128,149,123')
Geozone.find_by_census_code('Getafe-Norte').update(html_map_coordinates: '172,39,160,67,159,89,178,104,201,120,214,124,212,94,212,78,203,80,200,69,197,59')
Geozone.find_by_census_code('Juan de la Cierva').update(html_map_coordinates: '181,114,169,129,163,133,166,139,190,140,215,136,214,129,196,127')
Geozone.find_by_census_code('Los Molinos').update(html_map_coordinates: '219,80,217,93,220,119,234,115,242,119,249,121,258,117,270,113,275,104,273,92,261,86,239,85')
Geozone.find_by_census_code('Las Margaritas').update(html_map_coordinates: '158,73,144,107,151,123,155,116,167,125,181,112,157,95')
Geozone.find_by_census_code('Perales del Rio').update(html_map_coordinates: '360,70,365,96,375,93,390,97,424,98,437,108,447,101,453,107,463,99,430,74,407,65,398,62,392,56,380,59,374,53,366,58')
Geozone.find_by_census_code('San Isidro').update(html_map_coordinates: '128,165,125,196,135,186,148,182,154,170,142,170,135,172')
Geozone.find_by_census_code('Sector III').update(html_map_coordinates: '71,284,113,207,108,195,116,196,105,138,107,124,93,110,85,121,87,141,86,155,84,169,82,184,73,191,62,195,52,200,45,204,38,201,37,209,59,279')

Setting['credentials_generated_domain'] = 'ciudadanos.getafe.es'

Debate.create(title: 'Pregunta 1. Plan Normativo 2017', description: '¿Consideras en el Plan Presentado debe incluirse algún asunto determinado?, ¿qué enfoque te gustaría darle?.', author_id: 1, terms_of_service: '1' )
Debate.create(title: 'Pregunta 2. Plan Normativo 2017', description: '¿Crees necesaria la revisión o la redacción de alguna ordenanza o reglamento que no esté recogido en el Plan Normativo 2017?', author_id: 1, terms_of_service: '1' )
