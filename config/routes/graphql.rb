post "/graphql", to: "graphql#execute"
get "/graphql", to: "graphql#execute"
mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
