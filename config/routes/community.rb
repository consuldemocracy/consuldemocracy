resources :communities, only: [:show] do
  resources :topics
end

resolve("Topic") { |topic, options| [topic.community, topic, options] }
