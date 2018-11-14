### Admin
namespace :admin do
  resources :probes, only: [:index, :show]

  resource :stats, only: :show do
    get :spending_proposals, on: :collection
    get :budgets, on: :collection
    get :budget_supporting, on: :member
    get :budget_balloting, on: :member
    get :graph, on: :member
    get :proposal_notifications, on: :collection
    get :direct_messages, on: :collection
    get :redeemable_codes, on: :collection
    get :user_invites, on: :collection
    get :polls, on: :collection
  end

  resources :spending_proposals, only: [:index, :show, :edit, :update] do
    member do
      patch :assign_admin
      patch :assign_valuators
    end

    get :summary, on: :collection
    get :results, on: :collection
  end
end

### Budgets
get 'participatory_budget',                to: 'pages#show', id: 'budgets/welcome',            as: 'participatory_budget'
get 'presupuestos',                        to: 'budgets#index', id: 'help/budgets/welcome',    as: 'budgets_welcome'
get "presupuestos/:id/estadisticas",       to: "budgets/stats#show", as: 'custom_budget_stats'
get "presupuestos/:id/resultados",         to: "budgets/results#show", as: 'custom_budget_results'
get 'presupuestos/:id/ejecuciones',        to: 'budgets/executions#show', as: 'custom_budget_executions'
get "presupuestos/:id/resultados/:heading_id", to: "budgets/results#show", as: 'custom_budget_heading_result'

resources :budgets, only: [:show, :index], path: 'presupuestos' do
  resources :groups, controller: "budgets/groups", only: [:show], path: 'grupo'
  resources :investments, controller: "budgets/investments", only: [:index, :show, :new, :create, :destroy], path: 'proyecto' do
    member do
      post :vote
      put :flag
      put :unflag
    end

    collection { get :suggest }
  end

  resource :ballot, only: :show, controller: "budgets/ballots" do
    resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
  end

  resources :recommendations, controller: "budgets/recommendations", only: [:index, :new, :create, :destroy]

  resource :results, only: :show, controller: "budgets/results"
  resource :stats, only: :show, controller: "budgets/stats"
  resource :executions, only: :show, controller: 'budgets/executions'
end

get "presupuestos/:budget_id/:id/:heading_id", to: "budgets/investments#index", as: 'custom_budget_investments'
get "presupuestos/:budget_id/:id", to: "budgets/groups#show", as: 'custom_budget_group'
get "participatory_budget/investment_projects/:id", to: "budgets/investments#redirect_to_new_url", as: 'spending_proposals_to_budget_investments'

scope '/participatory_budget' do
  resources :spending_proposals, only: [:index, :destroy], path: 'investment_projects', controller: "budgets/investments" do #[:new, :create] temporary disabled
    get :welcome, on: :collection
    get :stats, on: :collection
    post :vote, on: :member
  end

  resource :ballot, only: [:show] do
    resources :ballot_lines, only: [:create, :destroy], shallow: true
  end

  resource :budget_poll, only: [:show, :new, :create] do
    get :thanks, on: :collection
  end
end

### Delegation
resources :forums, only: [:index, :create, :show]
resources :representatives, only: [:create, :destroy]

### Human Rights
resources :human_rights, only: [:index, :show]

### Legislations
resources :legacy_legislations, only: [:show], path: 'legislations'

resources :annotations do
  get :search, on: :collection
end

### Guides
resources :guides, only: :new

### Officing
namespace :officing do
 resources :polls, only: [:index] do
   get :final, on: :collection

   resources :results, only: [:new, :create, :index]

   resources :nvotes, only: :new do
     get :thanks, on: :collection
   end

   resources :ballot_sheets, only: [:new, :create, :show, :index]
 end

 resource :booth, controller: "booth", only: [:new, :create]
 resource :residence, controller: "residence", only: [:new, :create]
 resources :letters, only: [:new, :create, :show] do
   get :verify_name, on: :member
 end
 resources :voters, only: [:new, :create] do
   get :vote_with_tablet, on: :member
 end

 resource :session, only: [:new, :create]
 root to: "dashboard#index"
end

### Open Plenary
resources :open_plenaries, only: [] do
  get :results, on: :collection
end

### Probes
resources :probes, only: [:show] do
  post :selection,  on: :collection

  resources :probe_options, only: :show do
    post :discard, on: :member
    post :restore_discarded, on: :collection
  end
end


### Polls
get 'procesos',  to: 'legislation/processes#index', as: 'processes'
get "vota/stats_2018", to: "polls#stats_2018", as: 'poll_stats_2018'
get "vota/results_2018", to: "polls#results_2018", as: 'poll_results_2018'

resources :answers, only: [:index, :new, :create]

resources :polls, only: [:show, :index], path: 'vota' do
  member do
    get :stats
    get :results
  end
  resources :questions, controller: 'polls/questions', shallow: true do
    post :answer, on: :member
  end
  resources :nvotes, only: [:new], controller: 'polls/nvotes' do
    get :token, on: :collection
  end
end
post "/polls/nvotes/success" => "polls/nvotes#success", as: :polls_nvotes_success


### Verification
get "/verifica", to: "verification/letter#edit"

### Volunteers
resource :volunteer_poll, only: [:new, :create] do
  get :thanks, on: :collection
end

########## Named Routes ###########

# Budgets
get 'presupuestos-participativos-2017-videos',     to: 'pages#show', id: 'landings/budgets_videos_2017',    as: 'budgets_videos_2017'
get 'presupuestos-participativos-2017-materiales', to: 'pages#show', id: 'landings/budgets_materials_2017', as: 'budgets_materials_2017'
get 'presupuestos-participativos-2018-materiales', to: 'pages#show', id: 'landings/budgets_materials_2018', as: 'budgets_materials_2018'
get 'como-votar-presupuestos-participativos-2018', to: 'pages#show', id: 'landings/budgets_voting_2018',    as: 'budgets_voting_2018'
get 'participatory_budget/select_district',        to: 'spending_proposals#select_district', as: 'select_district'
get 'delegacion',                                  to: 'forums#index', as: 'delegation'
get 'presupuestos-participativos-resultados',      to: 'spending_proposals#results',                    as: 'participatory_budget_results'
get 'presupuestos-participativos-estadisticas',    to: 'spending_proposals#stats',                      as: 'participatory_budget_stats'
get 'presupuestos-participativos-ejecuciones',     to: 'budgets/executions#show',                       as: 'participatory_budget_executions', defaults: {id: '2016'}
get 'participatory_budget_info',                   to: 'pages#show', id: 'help/budgets/info_2016', as: 'more_info_budgets_2016'
get 'jornada-presupuestos-participativos',         to: 'budget_polls#new'
get 'jornada-presupuestos-participativos/success', to: 'budget_polls#success'

# Blog
get '/blog' => redirect('http://diario.madrid.es/decidemadrid/')

# Human Rights
get 'derechos-humanos',                  to: 'pages#show', id: 'processes/human_rights/index',      as: 'human_rights_page'
get 'derechos-humanos/plan',             to: 'pages#show', id: 'processes/human_rights/plan',       as: 'human_rights_plan'
get 'derechos-humanos/medidas',          to: 'human_rights#index',                                  as: 'human_rights_proposals'
get 'derechos-humanos/medidas/:id',      to: 'human_rights#show',                                   as: 'human_rights_proposal'
get 'processes/human_rights_question_2', to: 'pages#show', id: 'processes/human_rights/question_2', as: 'human_rights_question_2'
get 'processes/human_rights_question_3', to: 'pages#show', id: 'processes/human_rights/question_3', as: 'human_rights_question_3'

# Landings
get 'g1000',           to: 'pages#show', id: 'landings/g1000',            as: 'g1000'
get 'haz-propuestas',  to: 'pages#show', id: 'landings/blas_bonilla',     as: 'blas_bonilla'
get 'sitesientesgato', to: 'pages#show', id: 'landings/sitesientesgato',  as: 'sitesientesgato'
get 'haz-madrid',      to: 'pages#show', id: 'landings/geocraft',         as: 'geocraft'
get 'noticias',        to: 'pages#show', id: 'landings/news'

# More information pages
get 'mas-informacion/',                            to: 'pages#show', id: 'help/index',                  as: 'help'
get 'mas-informacion/como-usar',                   to: 'pages#show', id: 'help/how_to_use/index',       as: 'how_to_use'
get 'mas-informacion/faq',                         to: 'pages#show', id: 'help/faq/index',              as: 'faq'
get 'mas-informacion/debates',                     to: 'pages#show', id: 'help/debates/index',          as: 'more_info_debates'
get 'mas-informacion/propuestas',                  to: 'pages#show', id: 'help/proposals/index',        as: 'more_info_proposals'
get 'mas-informacion/votaciones',                  to: 'pages#show', id: 'help/polls/index',            as: 'more_info_polls'
get 'mas-informacion/procesos',                    to: 'pages#show', id: 'help/processes/index',        as: 'more_info_processes'
get 'mas-informacion/votaciones/febrero-2017',     to: 'pages#show', id: 'help/polls/february_2017',    as: 'more_info_polls_february'
get 'mas-informacion/votaciones/octubre-2017',     to: 'pages#show', id: 'help/polls/october_2017',     as: 'more_info_polls_october'
get 'mas-informacion/presupuestos-participativos', to: 'pages#show', id: 'help/budgets/index',          as: 'more_info_budgets'
get 'mas-informacion/espacios-presenciales-2016',  to: 'pages#show', id: 'help/budgets/meetings_2016',  as: 'budgets_meetings_2016'
get 'mas-informacion/espacios-presenciales-2017',  to: 'pages#show', id: 'help/budgets/meetings_2017',  as: 'budgets_meetings_2017'
get 'mas-informacion/participacion/hechos',        to: 'pages#show', id: 'help/participation/facts',    as: 'participation_facts'
get 'mas-informacion/participacion/mundo',         to: 'pages#show', id: 'help/participation/world',    as: 'participation_world'
get 'mas-informacion/derechos-humanos',            to: 'pages#show', id: 'help/participation/ddhh',     as: 'more_info_human_rights'
get 'mas-informacion/gobierno-abierto',            to: 'pages#show', id: 'help/participation/open',     as: 'participation_open_government'
get 'mas-informacion/foros-locales',               to: 'pages#show', id: 'help/participation/forums',   as: 'participation_forums'
get 'mas-informacion/kit-decide',                  to: 'pages#show', id: 'help/kit_decide/index',       as: 'kit_decide'

# Once plazas results & stats
get 'resultados-once-plazas',    to: 'polls#results_2018',  as: 'once_plazas_results'
get 'estadisticas-once-plazas',  to: 'polls#stats_2018',    as: 'once_plazas_stats'

# Polls 2016
get 'encuesta-plaza-espana' => redirect('/encuesta-plaza-espana-resultados')

# Polls 2017 results & stats
get 'primera-votacion-ciudadana-estadisticas', to: 'polls#stats_2017',    as: 'primera_votacion_stats'
get 'primera-votacion-ciudadana-informacion',  to: 'polls#info_2017',     as: 'primera_votacion_info'
get 'primera-votacion-ciudadana-resultados',   to: 'polls#results_2017',  as: 'first_voting'

# Processes
get 'proceso/licencias-urbanisticas',                 to: 'pages#show', id: 'processes/urbanistic/index',       as: 'urbanistic_licenses'
get 'proceso/alianza-gobierno-abierto',               to: 'pages#show', id: 'processes/open_government/index',  as: 'open_government'
get 'proceso/alianza-gobierno-abierto-borrador',      to: 'pages#show', id: 'processes/open_government/doc',    as: 'open_government_doc'
get 'proceso/ordenanza-subvenciones',                 to: 'pages#show', id: 'processes/subvention/index',       as: 'subvention_ordinance'
get 'proceso/plan-calidad-aire',                      to: 'pages#show', id: 'processes/air_quality_plan/index', as: 'air_quality_plan'
get 'proceso/rotulacion-vias',                        to: 'pages#show', id: 'processes/label_streets/index',    as: 'label_streets'
get 'proceso/distrito-villa-de-vallecas',             to: 'pages#show', id: 'processes/vallecas/index',         as: 'vallecas'
get 'proceso/linea-madrid',                           to: 'pages#show', id: 'processes/linea_madrid/index',     as: 'linea_madrid'
get 'proceso/nueva-ordenanza-movilidad',              to: 'pages#show', id: 'processes/movilidad/index',        as: 'movilidad'
get 'proceso/conservacion-rehabilitacion-edificios',  to: 'pages#show', id: 'processes/buildings/index',        as: 'buildings'
get 'proceso/ordenanza-publicidad-exterior',          to: 'pages#show', id: 'processes/publicity/index',        as: 'publicity'
get 'proceso/distrito-vicalvaro',                     to: 'pages#show', id: 'processes/vicalvaro/index',        as: 'vicalvaro'
get 'proceso/distrito-villaverde',                    to: 'pages#show', id: 'processes/villaverde/index',       as: 'villaverde'
get 'proceso/cartas-de-servicios',                    to: 'pages#show', id: 'processes/service_letters/index',  as: 'service_letters'
get 'proceso/cartas-de-servicios/1',                  to: 'pages#show', id: 'processes/service_letters/1',      as: 'service_letters_1'
get 'proceso/cartas-de-servicios/2',                  to: 'pages#show', id: 'processes/service_letters/2',      as: 'service_letters_2'
get 'proceso/cartas-de-servicios/3',                  to: 'pages#show', id: 'processes/service_letters/3',      as: 'service_letters_3'
get 'proceso/cartas-de-servicios/4',                  to: 'pages#show', id: 'processes/service_letters/4',      as: 'service_letters_4'
get 'proceso/cartas-de-servicios/5',                  to: 'pages#show', id: 'processes/service_letters/5',      as: 'service_letters_5'
get 'proceso/pleno-abierto',                          to: 'pages#show', id: 'processes/open_plenary/index',     as: 'open_plenary'
get 'proceso/ordenanza-de-transparencia',             to: 'pages#show', id: 'processes/transparency/index',     as: 'transparency_ordinance'
get 'proceso/ordenanza-de-transparencia/borrador',    to: 'pages#show', id: 'processes/transparency/draft',     as: 'transparency_ordinance_draft'
get 'proceso/registro-de-lobbies',                    to: 'pages#show', id: 'processes/lobbies/index',          as: 'lobbies'
get 'proceso/registro-de-lobbies/borrador',           to: 'pages#show', id: 'processes/lobbies/draft',          as: 'lobbies_draft'
get 'proceso/parque-lineal-manzanares',               to: 'pages#show', id: 'processes/manzanares/index',       as: 'manzanares'
get 'proceso/once-plazas',                            to: 'pages#show', id: 'processes/once_plazas/index',      as: 'once_plazas'
get 'plenoabierto',                                   to: 'legislation/processes#proposals', id: '24',          as: 'open_plenary_2017'
get 'plazas-abiertas',                                to: 'pages#show', id: 'landings/plazas_abiertas',         as: 'plazas_abiertas'
get 'filmotecas',                                     to: 'pages#show', id: 'processes/filmotecas/index',       as: 'filmotecas'

# Probes
get 'processes/urbanismo-bancos',         to: 'probes#show',    id: 'town_planning',   as: 'town_planning'
get 'processes/urbanismo-bancos-gracias', to: 'probes#thanks',  id: 'town_planning',   as: 'town_planning_thanks'

get 'proceso/plaza-espana-resultados',    to: 'probes#show',    id: 'plaza',                   as: 'plaza'
get 'proceso/plaza-espana',               to: 'probes#show',    id: 'plaza'
get 'proceso/plaza-espana-gracias',       to: 'probes#thanks',  id: 'plaza',                   as: 'plaza_thanks'
get 'proceso/plaza-espana-informacion',   to: 'pages#show',     id: 'plaza_espana/info',       as: 'remodeling_plaza'
get 'proceso/plaza-espana-debates',       to: 'pages#show',     id: 'plaza_espana/debates',    as: 'plaza_debates'
get 'proceso/plaza-espana-faq',           to: 'pages#show',     id: 'plaza_espana/faq',        as: 'plaza_faq'
get 'proceso/plaza-espana-estadisticas',  to: 'pages#show',     id: 'plaza_espana/results',    as: 'survey_plaza'
get 'proceso/plaza-espana/proyectos/:id', to: 'probe_options#show', probe_id: 'plaza',         as: 'plaza_probe_option'

# Terms and conditions
get 'accesibilidad',          to: 'pages#show', id: 'accessibility', as: 'accessibility'
get 'condiciones-de-uso',     to: 'pages#show', id: 'conditions',    as: 'conditions'
get 'politica-de-privacidad', to: 'pages#show', id: 'privacy',       as: 'privacy'

# Volunteers
get 'voluntarios-mesas-presenciales' => redirect('/volunteer_poll/new')

# Presupuestos participativos 2018
get '/presupuestos2018/1' => redirect('/presupuestos?pk_campaign=20180219_ParticipativosMadrid18&pk_source=bbdd_usuarios&pk_medium=email&pk_content=fin_plazo_presentacion_proyectos_link_footer')

# Custom pages
get '/como-crear-proyecto-presupuestos-participativos', to: 'pages#show', id: 'help/budgets/guide_2018', as: 'budgets_guide_2018'
