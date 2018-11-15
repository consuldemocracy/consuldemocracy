INVESTMENT_IMAGE_FILES = %w{
  brennan-ehrhardt-25066-unsplash_713x513.jpg
  carl-nenzen-loven-381554-unsplash_713x475.jpg
  carlos-zurita-215387-unsplash_713x475.jpg
  hector-arguello-canals-79584-unsplash_713x475.jpg
  olesya-grichina-218176-unsplash_713x475.jpg
  sole-d-alessandro-340443-unsplash_713x475.jpg
}.map do |filename|
  File.new(Rails.root.join("db",
                           "dev_seeds",
                           "images",
                           "budget",
                           "investments", filename))
end

def add_image_to(imageable)
  # imageable should respond to #title & #author
  imageable.image = Image.create!({
    imageable: imageable,
    title: imageable.title,
    attachment: INVESTMENT_IMAGE_FILES.sample,
    user: imageable.author
  })
  imageable.save
end

section "Creating Budgets" do
  finished_budget = Budget.create(
    name: "Budget #{Date.current.year - 1}",
    currency_symbol: "€",
    phase: 'finished'
  )

  accepting_budget = Budget.create(
    name: "Budget #{Date.current.year}",
    currency_symbol: "€",
    phase: 'accepting'
  )

  (1..([1, 2, 3].sample)).each do |i|
    finished_group  = finished_budget.groups.create!(name: "#{Faker::StarWars.planet} #{i}")
    accepting_group = accepting_budget.groups.create!(name: "#{Faker::StarWars.planet} #{i}")

    geozones = Geozone.reorder("RANDOM()").limit([2, 5, 6, 7].sample)
    geozones.each do |geozone|
      finished_group.headings << finished_group.headings.create!(name: "#{geozone.name} #{i}",
                                                                 price: rand(1..100) * 100000,
                                                                 population: rand(1..50) * 10000)

      accepting_group.headings << accepting_group.headings.create!(name: "#{geozone.name} #{i}",
                                                                   price: rand(1..100) * 100000,
                                                                   population: rand(1..50) * 10000)

    end
  end
end



section "Creating City Heading" do
  Budget.first.groups.first.headings.create(name: "Toda la ciudad", price: 100_000_000)
end

section "Creating Investments" do
  tags = Faker::Lorem.words(10)
  100.times do
    heading = Budget::Heading.reorder("RANDOM()").first

    investment = Budget::Investment.create!(
      author: User.reorder("RANDOM()").first,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: %w{undecided unfeasible feasible feasible feasible feasible}.sample,
      unfeasibility_explanation: Faker::Lorem.paragraph,
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(','),
      price: rand(1..100) * 100000,
      skip_map: "1",
      terms_of_service: "1"
    )

    add_image_to(investment) if Random.rand > 0.5
  end
end

section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.reorder("RANDOM()").first.update(visible_to_valuators: true)
  end
end

section "Geolocating Investments" do
  Budget.find_each do |budget|
    budget.investments.each do |investment|
      MapLocation.create(latitude: Setting['map_latitude'].to_f + rand(-10..10)/100.to_f,
                         longitude: Setting['map_longitude'].to_f + rand(-10..10)/100.to_f,
                         zoom: Setting['map_zoom'],
                         investment_id: investment.id)
    end
  end
end

section "Balloting Investments" do
  Budget.finished.first.investments.last(20).each do |investment|
    investment.update(selected: true, feasibility: "feasible")
  end
end

section "Voting Investments" do
  not_org_users = User.where(['users.id NOT IN(?)', User.organizations.pluck(:id)])
  100.times do
    voter = not_org_users.level_two_or_three_verified.reorder("RANDOM()").first
    investment = Budget::Investment.reorder("RANDOM()").first
    investment.vote_by(voter: voter, vote: true)
  end
end

section "Balloting Investments" do
  100.times do
    budget = Budget.finished.reorder("RANDOM()").first
    ballot = Budget::Ballot.create(user: User.reorder("RANDOM()").first, budget: budget)
    ballot.add_investment(budget.investments.reorder("RANDOM()").first)
  end
end

section "Winner Investments" do
  budget = Budget.finished.first
  50.times do
    heading = budget.headings.all.sample
    investment = Budget::Investment.create!(
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: "feasible",
      valuation_finished: true,
      selected: true,
      price: rand(10000..heading.price),
      skip_map: "1",
      terms_of_service: "1"
    )
    add_image_to(investment) if Random.rand > 0.3
  end
  budget.headings.each do |heading|
    Budget::Result.new(budget, heading).calculate_winners
  end
end

section "Creating Valuator Groups Assignments" do
  valuators_count = Valuator.count
  ValuatorGroup.create(name: I18n.t('seeds.budgets.valuator_groups.culture_and_sports'),
                       valuators: [Valuator.find(1), Valuator.find(2)])
  ValuatorGroup.create(name: I18n.t('seeds.budgets.valuator_groups.gender_and_diversity'),
                       valuators: [Valuator.find(3), Valuator.find(4)])
  ValuatorGroup.create(name: I18n.t('seeds.budgets.valuator_groups.urban_development'),
                       valuators: [Valuator.find(5), Valuator.find(6)])
  ValuatorGroup.create(name: I18n.t('seeds.budgets.valuator_groups.equity_and_employment'),
                       valuators: [Valuator.find(7), Valuator.find(8)])
end

section "Creating Valuation direct Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuators << Valuator.all.sample
  end
end

section "Creating Valuation Group Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuator_groups << ValuatorGroup.all.sample
  end
end

section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.reorder("RANDOM()").first.update(visible_to_valuators: true)
  end
end
