namespace :sdg_management do
  root to: "goals#index"

  resources :goals, only: [:index]
  resources :targets, only: [:index]
  resources :local_targets, except: [:show]

  types = SDG::Related::RELATABLE_TYPES.map(&:tableize)
  types_constraint = /#{types.join("|")}/

  get "*relatable_type", to: "relations#index", as: "relations", relatable_type: types_constraint

  types.each do |type|
    get type, to: "relations#index", as: type
  end
end
