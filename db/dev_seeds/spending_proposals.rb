section "Creating Spending Proposals" do
  tags = Faker::Lorem.words(10)
  60.times do
    geozone = Geozone.all.sample
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    feasible_explanation = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    valuation_finished = [true, false].sample
    feasible = [true, false].sample
    created_at = rand((Time.current - 1.week)..Time.current)
    spending_proposal = SpendingProposal.create!(author: author,
                                                 title: Faker::Lorem.sentence(3).truncate(60),
                                                 external_url: Faker::Internet.url,
                                                 description: description,
                                                 created_at: created_at,
                                                 geozone: [geozone, nil].sample,
                                                 feasible: feasible,
                                                 feasible_explanation: feasible_explanation,
                                                 valuation_finished: valuation_finished,
                                                 tag_list: tags.sample(3).join(','),
                                                 price: rand(1000000),
                                                 terms_of_service: "1")
  end
end

section "Creating Valuation Assignments" do
  (1..17).to_a.sample.times do
    SpendingProposal.all.sample.valuators << Valuator.first
  end
end
