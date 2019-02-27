section "Creating Debates" do
  tags = Faker::Lorem.words(25)
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    Debate.create!(author: author,
                   title: Faker::Lorem.sentence(3).truncate(60),
                   created_at: rand((Time.current - 1.week)..Time.current),
                   description: description,
                   tag_list: tags.sample(3).join(","),
                   geozone: Geozone.all.sample,
                   terms_of_service: "1")
  end

  tags = ActsAsTaggableOn::Tag.where(kind: "category")
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    Debate.create!(author: author,
                   title: Faker::Lorem.sentence(3).truncate(60),
                   created_at: rand((Time.current - 1.week)..Time.current),
                   description: description,
                   tag_list: tags.sample(3).join(","),
                   geozone: Geozone.all.sample,
                   terms_of_service: "1")
  end
end

section "Open plenary" do
  open_plenary = Debate.create!(author: User.reorder("RANDOM()").first,
                                title: "Pregunta en el Pleno Abierto",
                                created_at: Date.parse("20-04-2016"),
                                description: "<p>Pleno Abierto preguntas</p>",
                                terms_of_service: "1",
                                tag_list: "plenoabierto",
                                comment_kind: "question")

  (1..30).each do |_i|
    author = User.reorder("RANDOM()").first
    cached_votes_up = rand(1000)
    cached_votes_down = rand(1000)
    cached_votes_total =  cached_votes_up + cached_votes_down
    Comment.create!(user: author,
                    created_at: rand(open_plenary.created_at..Time.now),
                    commentable: open_plenary,
                    body: Faker::Lorem.sentence,
                    cached_votes_up: cached_votes_up,
                    cached_votes_down: cached_votes_down,
                    cached_votes_total: cached_votes_total)
  end
end
