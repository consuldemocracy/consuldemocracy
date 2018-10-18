section "Creating comment notifications" do
  User.find_each do |user|
    debate = Debate.create!(author: user,
                            title: Faker::Lorem.sentence(3).truncate(60),
                            description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
                            tag_list: ActsAsTaggableOn::Tag.all.sample(3).join(','),
                            geozone: Geozone.reorder("RANDOM()").first,
                            terms_of_service: "1")

    comment = Comment.create!(user: User.reorder("RANDOM()").first,
                              body: Faker::Lorem.sentence,
                              commentable: debate)

    Notification.add(user, comment)
  end
end