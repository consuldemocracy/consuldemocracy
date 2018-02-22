section "Creating Debates" do
  tags = Faker::Lorem.words(25)
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    debate = Debate.create!(author: author,
                            title: Faker::Lorem.sentence(3).truncate(60),
                            created_at: rand((Time.current - 1.week)..Time.current),
                            description: description,
                            tag_list: tags.sample(3).join(','),
                            geozone: Geozone.all.sample,
                            terms_of_service: "1")
  end

  tags = ActsAsTaggableOn::Tag.where(kind: 'category')
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    debate = Debate.create!(author: author,
                            title: Faker::Lorem.sentence(3).truncate(60),
                            created_at: rand((Time.current - 1.week)..Time.current),
                            description: description,
                            tag_list: tags.sample(3).join(','),
                            geozone: Geozone.all.sample,
                            terms_of_service: "1")
  end
end
