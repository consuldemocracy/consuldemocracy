def add_image_to_investment(investment)
  image_files = %w[
    brennan-ehrhardt-25066-unsplash_713x513.jpg
    carl-nenzen-loven-381554-unsplash_713x475.jpg
    carlos-zurita-215387-unsplash_713x475.jpg
    hector-arguello-canals-79584-unsplash_713x475.jpg
    olesya-grichina-218176-unsplash_713x475.jpg
    sole-d-alessandro-340443-unsplash_713x475.jpg
  ].map do |filename|
    Rails.root.join("db",
                    "dev_seeds",
                    "images",
                    "budget",
                    "investments", filename)
  end

  add_image_to(investment, image_files)
end

section "Creating Budgets" do
  Budget.create!(
    {
      currency_symbol: I18n.t("seeds.budgets.currency"),
      phase: "finished",
      published: true
    }.merge(
      random_locales_attributes(name: -> { "#{I18n.t("seeds.budgets.budget")} #{Date.current.year - 1}" })
    )
  )

  Budget.create!(
    {
      currency_symbol: I18n.t("seeds.budgets.currency"),
      phase: "accepting",
      published: true
    }.merge(
      random_locales_attributes(name: -> { "#{I18n.t("seeds.budgets.budget")} #{Date.current.year}" })
    )
  )

  Budget.find_each do |budget|
    budget.phases.each do |phase|
      phase.update!(random_locales_attributes(
        name: -> { I18n.t("budgets.phase.#{phase.kind}") },
        summary: -> { I18n.t("seeds.budgets.phases.summary", language: I18n.t("i18n.language.name")) },
        description: -> { I18n.t("seeds.budgets.phases.description", language: I18n.t("i18n.language.name")) }
      ))
    end
  end

  Budget.find_each do |budget|
    city_group = budget.groups.create!(
      random_locales_attributes(name: -> { I18n.t("seeds.budgets.groups.all_city") })
    )

    city_group.headings.create!(
      {
        price: 1000000,
        population: 1000000,
        latitude: "40.416775",
        longitude: "-3.703790"
      }.merge(
        random_locales_attributes(name: -> { I18n.t("seeds.budgets.groups.all_city") })
      )
    )

    districts_group = budget.groups.create!(
      random_locales_attributes(name: -> { I18n.t("seeds.budgets.groups.districts") })
    )

    [
      random_locales_attributes(name: -> { I18n.t("seeds.geozones.north_district") }).merge(
        population: 350000
      ),
      random_locales_attributes(name: -> { I18n.t("seeds.geozones.west_district") }).merge(
        population: 300000
      ),
      random_locales_attributes(name: -> { I18n.t("seeds.geozones.east_district") }).merge(
        population: 200000
      ),
      random_locales_attributes(name: -> { I18n.t("seeds.geozones.central_district") }).merge(
        population: 150000
      )
    ].each do |heading_params|
      districts_group.headings.create!(heading_params.merge(
        price: rand(5..10) * 100000,
        latitude: "40.416775",
        longitude: "-3.703790"
      ))
    end
  end
end

section "Creating Investments" do
  tags = Faker::Lorem.words(number: 10)
  100.times do
    heading = Budget::Heading.sample

    translation_attributes = random_locales.each_with_object({}) do |locale, attributes|
      attributes["title_#{locale.to_s.underscore}"] = "Title for locale #{locale}"
      attributes["description_#{locale.to_s.underscore}"] = "<p>Description for locale #{locale}</p>"
    end

    investment = Budget::Investment.create!({
      author: User.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      created_at: rand((1.week.ago)..Time.current),
      feasibility: %w[undecided unfeasible feasible feasible feasible feasible].sample,
      unfeasibility_explanation: Faker::Lorem.paragraph,
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(","),
      price: rand(1..100) * 100000,
      terms_of_service: "1"
    }.merge(translation_attributes))

    add_image_to_investment(investment) if Random.rand > 0.5
  end
end

section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.sample.update(visible_to_valuators: true)
  end
end

section "Geolocating Investments" do
  Budget.find_each do |budget|
    budget.investments.each do |investment|
      MapLocation.create(latitude: Setting["map.latitude"].to_f + rand(-10..10) / 100.to_f,
                         longitude: Setting["map.longitude"].to_f + rand(-10..10) / 100.to_f,
                         zoom: Setting["map.zoom"],
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
    heading = budget.headings.sample
    investment = Budget::Investment.create!(
      author: User.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(word_count: 3).truncate(60),
      description: "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>",
      created_at: rand((1.week.ago)..Time.current),
      feasibility: "feasible",
      valuation_finished: true,
      selected: true,
      price: rand(10000..heading.price),
      terms_of_service: "1"
    )
    add_image_to_investment(investment) if Random.rand > 0.3
  end
  budget.headings.each do |heading|
    Budget::Result.new(budget, heading).calculate_winners
  end
end

section "Creating Valuation Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.sample.valuators << Valuator.first
  end
end
