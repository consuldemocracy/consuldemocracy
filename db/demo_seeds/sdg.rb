section "Creating DEMO Sustainable Development Goals" do
  load Rails.root.join("db", "sdg.rb")

  relatables = [Debate, Proposal, Poll, Legislation::Process, Budget::Investment]
  relatables.map { |relatable| relatable.sample(5) }.flatten.each do |relatable|
    Array(SDG::Goal.sample(rand(1..3))).each do |goal|
      target = goal.targets.sample
      relatable.sdg_goals << goal
      relatable.sdg_targets << target
    end
  end
end

section "Creating DEMO SDG homepage cards" do
  card = Widget::Card.create!(cardable: SDG::Phase.first,
                              title: "What is your proposal?",
                              description: "Submit your citizen proposal. Organize a community around your proposal, find the support of your neighbors and when you have enough support, your proposal will be debated in the municipal plenary.",
                              link_url: "/proposals",
                              link_text: "Make your proposal",
                              label: "Ideas")

  card.image = Image.create!(imageable: card,
                             title: card.title,
                             attachment: Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "widgets", "decide-which-should-be-the-new-square.jpg")),
                             user_id: 1)

  card = Widget::Card.create!(cardable: SDG::Phase.second,
                              title: "The city that you want",
                              description: "Prioritization of different aspects of the city's development.",
                              link_url: "/polls",
                              link_text: "Participate",
                              label: "Polls")

  card.image = Image.create!(imageable: card,
                             title: card.title,
                             attachment: Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "polls", "light-of-the-city-1.jpg")),
                             user_id: 1)

  card = Widget::Card.create!(cardable: SDG::Phase.third,
                              title: "Comment the plan for a 100% green city",
                              description: "Inform yourself and comment on the proposal about the plan for a 100% green city",
                              link_url: "/proposals/1#tab-comments",
                              link_text: "See comments")

  card.image = Image.create!(imageable: card,
                             title: card.title,
                             attachment: Rack::Test::UploadedFile.new(Rails.root.join("db", "demo_seeds", "images", "proposals", "strategic-plan-for-a-100-green-city.jpg")),
                             user_id: 1)

end
