get 'pressupostos', to: 'budgets#index', id: 'help/budgets/welcome', as: 'budgets_welcome'
get 'pressupostos/:id', to: 'budgets#show',  as: 'custom_budget'

get 'concurs_cartell_magdalena', to: 'polls#current_cartell',  as: 'concurs_cartell_magdalena'
get 'concurs_cartell_magdalena/stats', to: 'polls#stats',  as: 'concurs_cartell_magdalena_stats'
get 'concurs_cartell_magdalena/results', to: 'polls#results',  as: 'concurs_cartell_magdalena_results'
