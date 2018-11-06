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
  Budget.create(
    name: "#{I18n.t('seeds.budgets.budget')} #{Date.current.year - 1}",
    currency_symbol: I18n.t('seeds.budgets.currency'),
    phase: 'finished'
  )
  Budget.create(
    name: "#{I18n.t('seeds.budgets.budget')} #{Date.current.year}",
    currency_symbol: I18n.t('seeds.budgets.currency'),
    phase: 'accepting'
  )

  Budget.all.each do |budget|
    city_group = budget.groups.create!(name: I18n.t('seeds.budgets.groups.all_city'))
    city_group.headings.create!(name: I18n.t('seeds.budgets.groups.all_city'),
                                price: 1000000,
                                population: 1000000)

    districts_group = budget.groups.create!(name: I18n.t('seeds.budgets.groups.districts'))
    districts_group.headings.create!(name: I18n.t('seeds.geozones.north_district'),
                                     price: rand(5..10) * 100000,
                                     population: 350000)
    districts_group.headings.create!(name: I18n.t('seeds.geozones.west_district'),
                                     price: rand(5..10) * 100000,
                                     population: 300000)
    districts_group.headings.create!(name: I18n.t('seeds.geozones.east_district'),
                                     price: rand(5..10) * 100000,
                                     population: 200000)
    districts_group.headings.create!(name: I18n.t('seeds.geozones.central_district'),
                                     price: rand(5..10) * 100000,
                                     population: 150000)
  end
end

section "Creating Investments" do
  tags = Faker::Lorem.words(10)
  100.times do
    heading = Budget::Heading.all.sample

    investment = Budget::Investment.create!(
      author: User.all.sample,
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

section "Creating Valuation Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuators << Valuator.first
  end
end

section "Creating investment milestones" do
  Budget::Investment.find_each do |investment|
    milestone = Budget::Investment::Milestone.new(investment_id: investment.id, publication_date: Date.tomorrow)
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        milestone.description = "Description for locale #{locale}"
        milestone.title = I18n.l(Time.current, format: :datetime)
        milestone.save!
      end
    end
  end
end

section "Creating default Investment Milestone Statuses" do
  Budget::Investment::Status.create(name: I18n.t('seeds.budgets.statuses.studying_project'))
  Budget::Investment::Status.create(name: I18n.t('seeds.budgets.statuses.bidding'))
  Budget::Investment::Status.create(name: I18n.t('seeds.budgets.statuses.executing_project'))
  Budget::Investment::Status.create(name: I18n.t('seeds.budgets.statuses.executed'))
end
