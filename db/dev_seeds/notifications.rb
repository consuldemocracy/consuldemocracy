section "Creating comment notifications" do
  User.find_each do |user|
    debate = Debate.create!(author: user,
                            title: Faker::Lorem.sentence(word_count: 3).truncate(60),
                            description: "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>",
                            tag_list: Tag.all.sample(3).join(","),
                            geozone: Geozone.sample,
                            terms_of_service: "1")

    comment = Comment.create!(user: User.sample,
                              body: Faker::Lorem.sentence,
                              commentable: debate)

    Notification.add(user, comment)
  end
end
