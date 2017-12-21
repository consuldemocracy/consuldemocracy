# not use compression
class SitemapGenerator::FileAdapter
  def gzip(stream, data); stream.write(data); stream.close end
end
SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(:sitemap, extension: '.xml')

# default host
SitemapGenerator::Sitemap.default_host = Setting["url"]

# sitemap generator
SitemapGenerator::Sitemap.create do
  pages = ["general_terms"]
  pages.each do |page|
    add page_path(id: page)
  end

  add debates_path, priority: 0.7, changefreq: "daily"
  Debate.find_each do |debate|
    add debate_path(debate), lastmod: debate.updated_at
  end

  add proposals_path, priority: 0.7, changefreq: "daily"
  Proposal.find_each do |proposal|
    add proposal_path(proposal), lastmod: proposal.updated_at
  end

  add budgets_path, priority: 0.7, changefreq: "daily"
  Budget.find_each do |budget|
    add budget_path(budget), lastmod: budget.updated_at
  end

  add polls_path, priority: 0.7, changefreq: "daily"
  Poll.find_each do |poll|
    add poll_path(poll), lastmod: poll.starts_at
  end

  add legislation_processes_path, priority: 0.7, changefreq: "daily"
  Legislation::Process.find_each do |process|
    add legislation_process_path(process), lastmod: process.start_date
  end

  # budgets
  add budgets_welcome_path

  # old processes
  add processes_path
  add urbanistic_licenses_path
  add open_government_path
  add open_government_doc_path
  add subvention_ordinance_path
  add air_quality_plan_path
  add label_streets_path
  add vallecas_path
  add linea_madrid_path
  add movilidad_path
  add buildings_path
  add publicity_path
  add vicalvaro_path
  add villaverde_path
  add service_letters_path
  add service_letters_1_path
  add service_letters_2_path
  add service_letters_3_path
  add service_letters_4_path
  add service_letters_5_path
  add open_plenary_path
  add transparency_ordinance_path
  add transparency_ordinance_draft_path
  add lobbies_path
  add lobbies_draft_path
  add manzanares_path

  # landings
  add g1000_path
  add blas_bonilla_path
  add sitesientesgato_path
  add plazas_abiertas_path
  add budgets_videos_2017_path

  # polls 2017 results & stats
  add primera_votacion_stats_path
  add primera_votacion_info_path
  add first_voting_path

  # more information pages
  add more_info_path
  add how_to_use_path
  add faq_path
  add more_info_proposals_path
  add more_info_budgets_path
  add participation_facts_path
  add participation_world_path
  add more_info_polls_path
  add kit_decide_path
  add budgets_meetings_2016_path
  add budgets_meetings_2017_path
  add more_info_human_rights_path
  add participation_open_government_path

  # proposals search by category
  add proposals_path(search: "Asociaciones")
  add proposals_path(search: "Cultura")
  add proposals_path(search: "Deportes")
  add proposals_path(search: "Derechos Sociales")
  add proposals_path(search: "Distritos")
  add proposals_path(search: "Economía")
  add proposals_path(search: "Empleo")
  add proposals_path(search: "Equidad")
  add proposals_path(search: "Medio Ambiente")
  add proposals_path(search: "Medios")
  add proposals_path(search: "Movilidad")
  add proposals_path(search: "Participación")
  add proposals_path(search: "Salud")
  add proposals_path(search: "Seguridad y Emergencias")
  add proposals_path(search: "Sostenibilidad")
  add proposals_path(search: "Transparencia")
  add proposals_path(search: "Urbanismo")

  # proposals search by district
  add proposals_path(search: "Arganzuela")
  add proposals_path(search: "Barajas")
  add proposals_path(search: "Carabanchel")
  add proposals_path(search: "Centro")
  add proposals_path(search: "Chamartín")
  add proposals_path(search: "Chamberí")
  add proposals_path(search: "Ciudad Lineal")
  add proposals_path(search: "Fuencarral-El Pardo")
  add proposals_path(search: "Hortaleza")
  add proposals_path(search: "Latina")
  add proposals_path(search: "Moncloa-Aravaca")
  add proposals_path(search: "Moratalaz")
  add proposals_path(search: "Puente de Vallecas")
  add proposals_path(search: "Retiro")
  add proposals_path(search: "Salamanca")
  add proposals_path(search: "San Blas-Canillejas")
  add proposals_path(search: "Tetuán")
  add proposals_path(search: "Usera")
  add proposals_path(search: "Vicálvaro")
  add proposals_path(search: "Villa de Vallecas")
  add proposals_path(search: "Villaverde")

end
