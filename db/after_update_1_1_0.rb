require "csv"
require "securerandom"
require "application_logger"

@logger = Logger.new(STDOUT)
@logger.formatter = proc do |_severity, _datetime, _progname, msg|
                      msg unless @avoid_log
                    end

def log(msg)
  @logger.info "#{msg}\n"
end

def section(section_title)
  @logger.info section_title
  yield
  log(" ✅")
end

@admin = nil

section "Creando usuario administrador para realizar las migraciones" do
  admin_password = SecureRandom.base64(15)
  @admin = User.create!(username: "Valladolid", email: "noreply@ava.es", password: admin_password,
                         password_confirmation: admin_password, confirmed_at: Time.current,
                         terms_of_service: "1", document_number: "00000001Z", document_type: "1",
                         verified_at: Time.now)
  @admin.create_administrator
end

section "Creando y personalizando configuraciones nuevas" do
  # Reiniciamos el contador de las claves primarias de todas las tablas
  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end

  # Funcionalidades custom
  Setting["feature.comments"] = true
  Setting["feature.direct_messages"] = true
  Setting["feature.ldap_login"] = true
  Setting["feature.codigo_login"] = true
  Setting["feature.physical_final_votes"] = true
  Setting["feature.admin_expire_passwords"] = false

  # Asignamos valores por defecto a algunas de las funcionalidades
  Setting["feature.google_login"] = false
  Setting["feature.facebook_login"] = false
  Setting["feature.twitter_login"] = false
  Setting["feature.user.skip_verification"] = false
  Setting["feature.direct_messages"] = false
  Setting["feature.remote_census"] = false
  Setting["feature.featured_proposals"] = false
  Setting["feature.public_stats"] = false
  Setting["feature.signature_sheets"] = false

  # Dejamos únicamente activado el apartado de budgets
  Setting["process.debates"] = false
  Setting["process.proposals"] = false
  Setting["process.polls"] = false
  Setting["process.budgets"] = true
  Setting["process.legislation"] = false

  # Configuración por defecto de los widgets de la página principal
  Setting["homepage.widgets.feeds.debates"] = false
  Setting["homepage.widgets.feeds.proposals"] = false
  Setting["homepage.widgets.feeds.processes"] = false

  # Subida de archivos
  Setting["uploads.images.content_types"] = "image/jpeg image/png"
  Setting["uploads.images.max_size"] = "2"

  # Redes sociales
  Setting["twitter_handle"] = "ayuntamientovll"
  Setting["facebook_handle"] = "AyuntamientodeValladolid"
  Setting["youtube_handle"] = "ValladolidAyto"
  Setting["instagram_handle"] = "ayuntamientovll"

  # Configuración por defecto del mapa
  Setting["feature.map"] = true
  Setting["map.latitude"] = "41.648737262859996"
  Setting["map.longitude"] = "-724.7286701202394"
  Setting["map.zoom"] = "12"

  # Configuración de URL de seguimiento de
  # presupuestos participativos anteriores
  Setting["budget_monitoring_url_2018"] = "https://cloud.valladolid.es/index.php/s/oXHrfDTwyvn63Vk#pdfviewer"
  Setting["budget_monitoring_url_2019"] = "https://cloud.valladolid.es/index.php/s/NvOzxxZrG95wzLY#pdfviewer"
end

section "Eliminando configuraciones obsoletas" do
  old_settings = [
    "per_page_code_head",
    "per_page_code_body",
    "blog_url",
    "transparency_url",
    "opendata_url",
    "place_name",
    "feature.debates",
    "feature.proposals",
    "feature.spending_proposals",
    "feature.polls",
    "feature.budgets",
    "feature.legislation",
    "feature.spending_proposal_features.voting_allowed",
    "banner-style.banner-style-one",
    "banner-style.banner-style-two",
    "banner-style.banner-style-three",
    "banner-img.banner-img-one",
    "banner-img.banner-img-two",
    "banner-img.banner-img-three",
    "verification_offices_url",
    "proposal_improvement_url",
    "feature.spending_proposals",
    "feature.spending_proposal_features.phase1",
    "feature.spending_proposal_features.phase2",
    "feature.spending_proposal_features.phase3",
    "feature.spending_proposal_features.voting_allowed",
    "feature.spending_proposal_features.final_voting_allowed",
    "feature.spending_proposal_features.open_results_page",
    "feature.spending_proposal_features.valuation_allowed"
  ]
  Setting.where(key: old_settings).destroy_all
end

section "Añadiendo configuraciones nuevas restantes" do
  Setting.add_new_settings
end

# PERSONALIZACIÓN DE LA WEB

section "Añadiendo enlaces en la cabecera" do
  site_customization_content_block_header_links = SiteCustomization::ContentBlock.where(name: "top_links").first_or_create
  site_customization_content_block_header_links.locale = "es"
  site_customization_content_block_header_links.body = "<li><a href=\"http://www.valladolid.es/es/ayuntamiento/portal-transparencia\">Transparencia</a></li>\r\n<li><a href=\"http://www.valladolid.es/es/temas/hacemos/open-data-datos-abiertos\">Datos abiertos</a></li>\r\n<li><a href=\"https://www.valladolid.es/es/ciudad/participacion-ciudadana/servicios/presupuestos-participativos-informes-anuales\">Informes de gestión anuales</a></li>"
  site_customization_content_block_header_links.save
end

section "Añadiendo contenido por defecto de la página de inicio" do
  Widget::Card.create!(
    header: true,
    title: "Presupuestos Participativos:",
    description: "
      <h3>TU VOZ en el Ayuntamiento de Valladolid</h3>
      <p>
        Nadie conoce mejor las necesidades de un barrio como sus propios vecinos y vecinas.<br>
        Por ello, te animamos a tomar parte de los <b style='color:#E6118F;'>Presupuestos Participativos</b> donde con <b style='color:#E6118F;'>TU VOZ</b> podrás tomar decisiones sobre en qué se invierte una parte del presupuesto municipal.
      </p>
    ",
    link_text: "Ver calendario",
    link_url: "https://www10.ava.es/presupuestosparticipativos/cronograma",
    image_attributes: {
      attachment: File.open(Rails.root.join("app/assets/images/custom/welcome.png")),
      title: "welcome.png",
      user: User.first
    }
  )
end

section "Añadiendo contenido por defecto en las diferentes secciones de la web" do
  WebSection.where(name: "homepage").first_or_create!
  WebSection.where(name: "debates").first_or_create!
  WebSection.where(name: "proposals").first_or_create!
  WebSection.where(name: "budgets").first_or_create!
  WebSection.where(name: "help_page").first_or_create!
end

# Contenido de las páginas custom
section "Añadiendo páginas personalizadas" do
  load Rails.root.join("db", "custom_pages", "faq.rb")
  load Rails.root.join("db", "custom_pages", "citizen_participation_in_the_world.rb")
  load Rails.root.join("db", "custom_pages", "facts_about_citizen_participation.rb")
  load Rails.root.join("db", "pages", "accessibility.rb")
  load Rails.root.join("db", "custom_pages", "welcome_level_three_verified.rb")
  load Rails.root.join("db", "custom_pages", "welcome_level_two_verified.rb")
  load Rails.root.join("db", "custom_pages", "welcome_not_verified.rb")
  load Rails.root.join("db", "custom_pages", "conditions.rb")
  load Rails.root.join("db", "custom_pages", "privacy.rb")
  load Rails.root.join("db", "custom_pages", "budgets_info.rb")
  load Rails.root.join("db", "custom_pages", "census_terms.rb")
end

# PROPUESTAS
section "Añadiendo páginas personalizadas" do
  Proposal.draft.find_each do |proposal|
    proposal.update_columns(published_at: proposal.created_at, updated_at: Time.current)
  end
end

section "Actualizando el campo hot_score en las propuestas" do
  Proposal.find_each do |proposal|
    new_hot_score = proposal.calculate_hot_score
    proposal.update_columns(hot_score: new_hot_score, updated_at: Time.current)
  end
end

section "Asociando 'communities' a las propuestas ciudadanas existentes" do
  Proposal.all.each do |proposal|
    if proposal.community.blank?
      community = Community.create!
      proposal.update!(community_id: community.id)
    end
  end
end

# PRESUPUESTOS PARTICIPATIVOS

section "Actualizando usuario de propuestas anónimas" do
  Budget::Investment.where(author_id: nil).each do |investment|
    investment.update_column(:author_id, @admin.id)
  end
end

# Algunas propuestas no tienen asignado el campo unfeasibility_explanation, para
# evitar problemas le asignaremos un valor por defecto
section "Actualizando descripción en las propuestas no viables" do
  Budget::Investment.where(feasibility: "unfeasible", unfeasibility_explanation: [nil, ""]).each do |investment|
    investment.update_column(:unfeasibility_explanation, "Propuesta no viable")
  end
end

section "Asociando 'communities' a las propuestas de los presupuestos participativos" do
  Budget::Investment.all.each do |investment|
    if investment.community.blank?
      community = Community.create!
      investment.update!(community_id: community.id)
    end
  end
end

section "Importando comentarios internos en los presupuestos participativos" do
  csv_investment_internal_comments_file = "#{Rails.root}/data/budgets_investments_internal_comments.csv"
  investment_internal_comments_author_id = @admin.id
  csv_investment_internal_comments_file_reader = File.read(csv_investment_internal_comments_file)
  csv_investment_internal_comments = CSV.parse(csv_investment_internal_comments_file_reader, headers: true, col_sep: "|")
  csv_investment_internal_comments.each do |row|
    investment = Budget::Investment.find_by(id: row["id"].to_i)
    if investment.present?
      comment = Comment.new(commentable: investment, user_id: investment_internal_comments_author_id,
                   body: row["internal_comments"], valuation: true)
      comment.save!(validate: false)
    end
  end
end

section "Creando fases en los presupuestos participativos existentes" do
  csv_budget_attributes_file = "#{Rails.root}/data/budgets_attributes.csv"
  budget_attributes_file_reader = File.read(csv_budget_attributes_file)
  csv_budgets_attributes = CSV.parse(budget_attributes_file_reader, headers: true, col_sep: "|")
  csv_budgets_attributes.each do |row|
    budget = Budget.find_by(id: row["id"].to_i)

    if budget.present?
      Budget::Phase::PHASE_KINDS.each do |phase|
        Budget::Phase.create!(
          budget: budget,
          kind: phase,
          description: row["description_#{phase}"],
          prev_phase: budget.phases&.last,
          starts_at: budget.phases&.last&.ends_at || Date.current,
          ends_at: (budget.phases&.last&.ends_at || Date.current) + 1.month,
          enabled: false
        )
      end
    end
  end
end

section "Ejecutando tarea 'calculate_ballot_lines de la versión 1.0.0 de Consul'" do
  Budget::Ballot.find_each.with_index do |ballot, index|
    Budget::Ballot.reset_counters ballot.id, :lines
  end
end

section "Actualizando los resultados y estadísticas en los presupuestos participativos" do
  Budget.find_each do |budget|
    next unless budget.report.new_record?
    budget.report.update!(results: true, stats: false, advanced_stats: false)
  end
end

section "Generando estadísticas sin cachear en los presupuestos participativos" do
  Budget.find_each do |budget|
    Budget::Stats.new(budget).generate
  end
end

section "Actualizando campo original_heading_id en las propuestas de los presupuestos participativos" do
  Budget::Investment.find_each do |investment|
    unless investment.original_heading_id.present?
      investment.update_column(:original_heading_id, investment.heading_id)
    end
  end
end

section "Migrando datos de evaluadores y administradores en la versión 1.1.0 de Consul" do
  Budget.find_each do |budget|
    investments = budget.investments.with_hidden

    administrator_ids = investments.where.not(administrator: nil).distinct.pluck(:administrator_id)
    administrator_ids = Administrator.where(id: administrator_ids).map(&:id)

    valuator_ids = Budget::ValuatorAssignment.where(investment: investments).distinct.pluck(:valuator_id)
    valuator_ids = Valuator.where(id: valuator_ids).map(&:id)

    budget.update!(
      administrator_ids: administrator_ids,
      valuator_ids: valuator_ids
    )
  end
end

section "Habilitando resultados en los presupuestos participativos finalizados" do
  Budget.finished.find_each do |budget|
    budget.results_enabled = true
    budget.save!
  end
end

# OTROS

section "Migraciones de datos pendientes en la versión 1.1.0 de Consul" do
  Tagging.where(context: "valuation").update_all(context: "valuation_tags")
end

section "Borrando la caché" do
  Rails.cache.clear
end
