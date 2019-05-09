section "Creating legislation people proposals" do
  10.times do
    Legislation::PeopleProposal.create!(title: Faker::Lorem.sentence(3).truncate(60),
                                        description: Faker::Lorem.paragraphs.join("\n\n"),
                                        question: Faker::Lorem.sentence(3),
                                        summary: Faker::Lorem.paragraph,
                                        author: User.all.sample,
                                        process: Legislation::Process.all.sample,
                                        terms_of_service: "1",
                                        validated: rand <= 2.0 / 3,
                                        selected: rand <= 1.0 / 3)
  end
end
