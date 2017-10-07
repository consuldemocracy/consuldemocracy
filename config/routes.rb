Rails.application.routes.draw do

  if Rails.env.development? || Rails.env.staging?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  devise_for :organizations, class_name: 'User',
                             controllers: {
                               registrations: 'organizations/registrations',
                               sessions: 'devise/sessions'
                             },
                             skip: [:omniauth_callbacks]

  devise_scope :organization do
    get 'organizations/sign_up/success', to: 'organizations/registrations#success'
  end

  devise_scope :user do
    patch '/user/confirmation', to: 'users/confirmations#update', as: :update_user_confirmation
    get '/user/registrations/check_username', to: 'users/registrations#check_username'
    get 'users/sign_up/success', to: 'users/registrations#success'
    get 'users/registrations/delete_form', to: 'users/registrations#delete_form'
    delete 'users/registrations', to: 'users/registrations#delete'
    get :finish_signup, to: 'users/registrations#finish_signup'
    patch :do_finish_signup, to: 'users/registrations#do_finish_signup'
  end

  root 'welcome#index'
  get '/welcome', to: 'welcome#welcome'
  get '/cuentasegura', to: 'welcome#verification', as: :cuentasegura

  resources :debates do
    member do
      post :vote
      put :flag
      put :unflag
      put :mark_featured
      put :unmark_featured
    end
    collection do
      get :map
      get :suggest
    end
  end

  resources :answers, only: [:index, :new, :create]

  resources :proposals do
    member do
      post :vote
      post :vote_featured
      put :flag
      put :unflag
      get :retire_form
      get :share
      patch :retire
    end
    collection do
      get :map
      get :suggest
      get :summary
    end
  end

  resources :comments, only: [:create, :show], shallow: true do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  get 'participatory_budget',                to: 'pages#show', id: 'budgets/welcome',            as: 'participatory_budget'
  get 'presupuestos', to: 'pages#show', id: 'more_info/budgets/welcome',  as: 'budgets_welcome'
  get "presupuestos/:id/estadisticas", to: "budgets/stats#show", as: 'custom_budget_stats'
  get "presupuestos/:id/resultados", to: "budgets/results#show", as: 'custom_budget_results'
  get "presupuestos/:id/resultados/:heading_id", to: "budgets/results#show", as: 'custom_budget_heading_result'

  resources :budgets, only: [:show, :index], path: 'presupuestos' do
    resources :groups, controller: "budgets/groups", only: [:show], path: 'grupo'
    resources :investments, controller: "budgets/investments", only: [:index, :show, :new, :create, :destroy], path: 'proyecto' do
      member do
        post :vote
      end
      collection { get :suggest }
    end
    resource :ballot, only: :show, controller: "budgets/ballots" do
      resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
    end

    resources :recommendations, controller: "budgets/recommendations", only: [:index, :new, :create, :destroy]

    resource :results, only: :show, controller: "budgets/results"
    resource :stats, only: :show, controller: "budgets/stats"
  end

  get "presupuestos/:budget_id/:id/:heading_id", to: "budgets/investments#index", as: 'custom_budget_investments'
  get "presupuestos/:budget_id/:id", to: "budgets/groups#show", as: 'custom_budget_group'

  scope '/participatory_budget' do
    resources :spending_proposals, only: [:index, :show, :destroy], path: 'investment_projects' do #[:new, :create] temporary disabled
      get :welcome, on: :collection
      get :stats, on: :collection
      post :vote, on: :member
    end

    resource :ballot, only: [:show] do
      resources :ballot_lines, only: [:create, :destroy], shallow: true
    end

  end

  resources :open_plenaries, only: [] do
    get :results, on: :collection
  end

  resources :follows, only: [:create, :destroy]

  resources :documents, only: [:destroy]

  resources :images, only: [:destroy]

  resources :direct_uploads, only: [:create]
  delete "direct_uploads/destroy", to: "direct_uploads#destroy", as: :direct_upload_destroy

  resources :stats, only: [:index]

  resources :legacy_legislations, only: [:show], path: 'legislations'

  resources :annotations do
    get :search, on: :collection
  end

  resources :polls, only: [:show, :index], path: 'votaciones' do
    resources :questions, controller: 'polls/questions', shallow: true do
      post :answer, on: :member
    end
    resources :nvotes, only: [:new], controller: 'polls/nvotes' do
      get :token, on: :collection
    end
  end
  post "/polls/nvotes/success" => "polls/nvotes#success", as: :polls_nvotes_success

  namespace :legislation do
    resources :processes, only: [:index, :show] do
      member do
        get :debate
        get :draft_publication
        get :allegations
        get :result_publication
      end
      resources :questions, only: [:show] do
        resources :answers, only: [:create]
      end
      resources :draft_versions, only: [:show] do
        get :go_to_version, on: :collection
        get :changes
        resources :annotations do
          get :search, on: :collection
          get :comments
          post :new_comment
        end
      end
    end
  end

  get 'procesos',  to: 'legislation/processes#index', as: 'processes'

  resources :users, only: [:show] do
    resources :direct_messages, only: [:new, :create, :show]
  end

  resource :account, controller: "account", only: [:show, :update, :delete] do
    get :erase, on: :collection
  end

  resources :notifications, only: [:index, :show] do
    put :mark_all_as_read, on: :collection
  end

  resources :proposal_notifications, only: [:new, :create, :show]

  resource :verification, controller: "verification", only: [:show]

  resources :communities, only: [:show] do
    resources :topics
  end

  scope module: :verification do
    resource :residence, controller: "residence", only: [:new, :create]
    resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
    resource :verified_user, controller: "verified_user", only: [:show]
    resource :email, controller: "email", only: [:new, :show, :create]
    resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
  end
  get "/verifica", to: "verification/letter#edit"

  resources :tags do
    collection do
      get :suggest
    end
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :organizations, only: :index do
      get :search, on: :collection
      member do
        put :verify
        put :reject
      end
    end

    resources :hidden_users, only: [:index, :show] do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :debates, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :proposals, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :spending_proposals, only: [:index, :show, :edit, :update] do
      member do
        patch :assign_admin
        patch :assign_valuators
      end

      get :summary, on: :collection
      get :results, on: :collection
    end

    resources :probes, only: [:index, :show]

    resources :budgets do
      member do
        put :calculate_winners
      end

      resources :budget_groups do
        resources :budget_headings do
        end
      end

      resources :budget_investments, only: [:index, :show, :edit, :update] do
        resources :budget_investment_milestones
        member { patch :toggle_selection }
      end
    end

    resources :signature_sheets, only: [:index, :new, :create, :show]

    resources :banners, only: [:index, :new, :create, :edit, :update, :destroy] do
      collection { get :search}
    end

    resources :comments, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :tags, only: [:index, :create, :update, :destroy]
    resources :officials, only: [:index, :edit, :update, :destroy] do
      get :search, on: :collection
    end

    resources :settings, only: [:index, :update]
    put :update_map, to: "settings#update_map"

    resources :moderators, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :valuators, only: [:index, :create] do
      get :search, on: :collection
      get :summary, on: :collection
    end

    resources :managers, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :administrators, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :users, only: [:index, :show]

    scope module: :poll do
      resources :polls do
        patch :add_question, on: :member

        resources :booth_assignments, only: [:index, :show, :create, :destroy] do
          get :search_booths, on: :collection
        end

        resources :officer_assignments, only: [:index, :create, :destroy] do
          get :search_officers, on: :collection
          get :by_officer, on: :collection
        end

        resources :recounts, only: :index
        resources :results, only: :index
      end

      resources :officers do
        get :search, on: :collection
      end

      resources :booths do
        get :available, on: :collection

        resources :shifts do
          get :search_officers, on: :collection
        end
      end

      resources :questions, shallow: true do
        resources :answers, except: [:index, :destroy], controller: 'questions/answers', shallow: true do
          resources :images, controller: 'questions/answers/images'
          resources :videos, controller: 'questions/answers/videos'
          get :documents, to: 'questions/answers#documents'
        end
      end
    end

    resources :verifications, controller: :verifications, only: :index do
      get :search, on: :collection
    end

    resource :activity, controller: :activity, only: :show
    resources :newsletters, only: :index do
      get :users, on: :collection
    end

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

    namespace :legislation do
      resources :processes do
        resources :questions
        resources :draft_versions
      end
    end

    namespace :legislation do
      resources :processes do
        resources :questions
        resources :draft_versions
      end
    end

    namespace :legislation do
      resources :processes do
        resources :questions
        resources :draft_versions
      end
    end

    namespace :api do
      resource :stats, only: :show
    end

    resources :geozones, only: [:index, :new, :create, :edit, :update, :destroy]

    namespace :site_customization do
      resources :pages, except: [:show]
      resources :images, only: [:index, :update, :destroy]
      resources :content_blocks, except: [:show]
    end
  end

  namespace :moderation do
    root to: "dashboard#index"

    resources :users, only: :index do
      member do
        put :hide
        put :hide_in_moderation_screen
      end
    end

    resources :debates, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :proposals, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :comments, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end
  end

  namespace :valuation do
    root to: "budgets#index"

    resources :spending_proposals, only: [:index, :show, :edit] do
      patch :valuate, on: :member
    end

    resources :budgets, only: :index do
      resources :budget_investments, only: [:index, :show, :edit] do
        patch :valuate, on: :member
      end
    end
  end

  namespace :management do
    root to: "dashboard#index"

    resources :document_verifications, only: [:index, :new, :create] do
      post :check, on: :collection
    end

    resources :email_verifications, only: [:new, :create]

    resources :user_invites, only: [:new, :create]

    resources :users, only: [:new, :create] do
      collection do
        delete :logout
        delete :erase
      end
    end

    resource :account, controller: "account", only: [:show]

    get 'sign_in', to: 'sessions#create', as: :sign_in

    resource :session, only: [:create, :destroy]
    resources :proposals, only: [:index, :new, :create, :show] do
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :spending_proposals, only: [:index, :show] do #[:new, :create] temporary disabled
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :budgets, only: :index do
      collection do
        get :create_investments
        get :support_investments
        get :print_investments
      end
      resources :investments, only: [:index, :new, :create, :show, :destroy], controller: 'budgets/investments' do
        post :vote, on: :member
        get :print, on: :collection
      end
    end
  end

  resources :forums, only: [:index, :create, :show]
  resources :representatives, only: [:create, :destroy]

  resources :probes, only: [:show] do
    post :selection,  on: :collection
    get :thanks, on: :collection

    resources :probe_options, only: :show do
      post :discard, on: :member
      post :restore_discarded, on: :collection
    end
  end

  resources :human_rights, only: [:index, :show]

  resource :volunteer_poll, only: [:new, :create] do
    get :thanks, on: :collection
  end

  namespace :officing do
    resources :polls, only: [:index] do
      get :final, on: :collection

      resources :results, only: [:new, :create, :index]

      resources :nvotes, only: :new do
        get :thanks, on: :collection
      end
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

  # GraphQL
  get '/graphql', to: 'graphql#query'
  post '/graphql', to: 'graphql#query'

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'

  get 'voluntarios-mesas-presenciales' => redirect('/volunteer_poll/new')
  get 'encuesta-plaza-espana' => redirect('/encuesta-plaza-espana-resultados')
  get '/blog' => redirect('http://diario.madrid.es/decidemadrid/')
  get 'participatory_budget/select_district', to: 'spending_proposals#select_district', as: 'select_district'
  get 'delegacion', to: 'forums#index', as: 'delegation'
  get 'presupuestos-participativos-resultados',   to: 'spending_proposals#results',                    as: 'participatory_budget_results'
  get 'presupuestos-participativos-estadisticas', to: 'spending_proposals#stats',                      as: 'participatory_budget_stats'
  get 'participatory_budget_info',                to: 'pages#show', id: 'more_info/budgets/info_2016', as: 'more_info_budgets_2016'

  #Probes
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

  #Human Rights
  get 'derechos-humanos',                  to: 'pages#show', id: 'processes/human_rights/index',      as: 'human_rights_page'
  get 'derechos-humanos/plan',             to: 'pages#show', id: 'processes/human_rights/plan',       as: 'human_rights_plan'
  get 'derechos-humanos/medidas',          to: 'human_rights#index',                                  as: 'human_rights_proposals'
  get 'derechos-humanos/medidas/:id',      to: 'human_rights#show',                                   as: 'human_rights_proposal'
  get 'processes/human_rights_question_2', to: 'pages#show', id: 'processes/human_rights/question_2', as: 'human_rights_question_2'
  get 'processes/human_rights_question_3', to: 'pages#show', id: 'processes/human_rights/question_3', as: 'human_rights_question_3'

  #Processes
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

  #Landings
  get 'g1000',           to: 'pages#show', id: 'landings/g1000',            as: 'g1000'
  get 'haz-propuestas',  to: 'pages#show', id: 'landings/blas_bonilla',     as: 'blas_bonilla'
  get 'sitesientesgato', to: 'pages#show', id: 'landings/sitesientesgato',  as: 'sitesientesgato'
  get 'haz-madrid',      to: 'pages#show', id: 'landings/geocraft',         as: 'geocraft'
  get 'noticias',        to: 'pages#show', id: 'landings/news'

  # Budgets 2017
  get 'plazas-abiertas', to: 'pages#show', id: 'landings/plazas_abiertas',  as: 'plazas_abiertas'
  get 'presupuestos-participativos-2017-videos',     to: 'pages#show', id: 'landings/budgets_videos_2017',    as: 'budgets_videos_2017'
  get 'presupuestos-participativos-2017-materiales', to: 'pages#show', id: 'landings/budgets_materials_2017', as: 'budgets_materials_2017'

  #Polls 2017 results & stats
  get 'primera-votacion-ciudadana-estadisticas', to: 'polls#stats_2017',    as: 'primera_votacion_stats'
  get 'primera-votacion-ciudadana-informacion',  to: 'polls#info_2017',     as: 'primera_votacion_info'
  get 'vota',                                    to: 'polls#results_2017',  as: 'first_voting'

  # more information pages
  get 'mas-informacion',                             to: 'pages#show', id: 'more_info/index',                 as: 'more_info'
  get 'mas-informacion-votacion-febrero-2017',       to: 'pages#show', id: 'more_info/index_february_2017',   as: 'more_info_february'
  get 'mas-informacion-votacion-octubre-2017',       to: 'pages#show', id: 'more_info/index_october_2017',    as: 'more_info_october'
  get 'mas-informacion/como-usar',                   to: 'pages#show', id: 'more_info/how_to_use/index',      as: 'how_to_use'
  get 'mas-informacion/faq',                         to: 'pages#show', id: 'more_info/faq/index',             as: 'faq'
  get 'mas-informacion/propuestas',                  to: 'pages#show', id: 'more_info/proposals/index',       as: 'more_info_proposals'
  get 'mas-informacion/presupuestos-participativos', to: 'pages#show', id: 'more_info/budgets/index',         as: 'more_info_budgets'
  get 'mas-informacion/participacion/hechos',        to: 'pages#show', id: 'more_info/participation/facts',   as: 'participation_facts'
  get 'mas-informacion/participacion/mundo',         to: 'pages#show', id: 'more_info/participation/world',   as: 'participation_world'
  get 'mas-informacion/votaciones',                  to: 'pages#show', id: 'more_info/polls/index',           as: 'more_info_polls'
  get 'mas-informacion/kit-decide',                  to: 'pages#show', id: 'more_info/kit_decide/index',      as: 'kit_decide'
  get 'mas-informacion/espacios-presenciales-2016',  to: 'pages#show', id: 'more_info/budgets/meetings_2016', as: 'budgets_meetings_2016'
  get 'mas-informacion/espacios-presenciales-2017',  to: 'pages#show', id: 'more_info/budgets/meetings_2017', as: 'budgets_meetings_2017'
  get 'mas-informacion/derechos-humanos',            to: 'pages#show', id: 'more_info/participation/ddhh',    as: 'more_info_human_rights'
  get 'mas-informacion/gobierno-abierto',            to: 'pages#show', id: 'more_info/participation/open',    as: 'participation_open_government'
  get 'mas-informacion/foros-locales',               to: 'pages#show', id: 'more_info/participation/forums',  as: 'participation_forums'

  #static pages
  get 'accesibilidad',          to: 'pages#show', id: 'accessibility', as: 'accessibility'
  get 'condiciones-de-uso',     to: 'pages#show', id: 'conditions',    as: 'conditions'
  get 'politica-de-privacidad', to: 'pages#show', id: 'privacy',       as: 'privacy'

  resources :pages, path: '/', only: [:show]
end
