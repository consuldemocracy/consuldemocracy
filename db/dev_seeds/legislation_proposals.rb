section "Creating legislation proposals" do
  10.times do
    Legislation::Proposal.create!(title: Faker::Lorem.sentence(word_count: 3).truncate(60),
                                  description: Faker::Lorem.paragraphs.join("\n\n"),
                                  summary: Faker::Lorem.paragraph,
                                  author: User.all.sample,
                                  process: Legislation::Process.all.sample,
                                  terms_of_service: "1",
                                  selected: rand <= 1.0 / 3)
  end
end
