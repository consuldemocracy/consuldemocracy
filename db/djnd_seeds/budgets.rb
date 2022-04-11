INVESTMENT_IMAGE_FILES = %w[
  brennan-ehrhardt-25066-unsplash_713x513.jpg
  carl-nenzen-loven-381554-unsplash_713x475.jpg
  carlos-zurita-215387-unsplash_713x475.jpg
  hector-arguello-canals-79584-unsplash_713x475.jpg
  olesya-grichina-218176-unsplash_713x475.jpg
  sole-d-alessandro-340443-unsplash_713x475.jpg
].map do |filename|
  File.new(Rails.root.join("db",
                           "dev_seeds",
                           "images",
                           "budget",
                           "investments", filename))
end

PHASES_TO_DISABLE = %w[selecting valuating publishing_prices].freeze

def add_image_to(imageable)
  # imageable should respond to #title & #author
  imageable.image = Image.create!({
                                    imageable: imageable,
                                    title: imageable.title,
                                    attachment: INVESTMENT_IMAGE_FILES.sample,
                                    user: imageable.author
                                  })
  imageable.save!
end

section "Creating Budgets" do
  Budget.create!(
    name: "Testni budget #{Date.current.year}",
    currency_symbol: I18n.t("seeds.budgets.currency"),
    phase: "accepting"
  )

  Budget.all.each do |budget|
    city_group = budget.groups.create!(name: I18n.t("seeds.budgets.groups.all_city"))
    city_group.headings.create!(name: I18n.t("seeds.budgets.groups.all_city"),
                                price: 1000000,
                                population: 1000000)

    districts_group = budget.groups.create!(name: I18n.t("seeds.budgets.groups.districts"))
    districts_group.headings.create!(name: I18n.t("seeds.geozones.north_district"),
                                     price: rand(5..10) * 100000,
                                     population: 350000)
    districts_group.headings.create!(name: I18n.t("seeds.geozones.west_district"),
                                     price: rand(5..10) * 100000,
                                     population: 300000)
    districts_group.headings.create!(name: I18n.t("seeds.geozones.east_district"),
                                     price: rand(5..10) * 100000,
                                     population: 200000)
    districts_group.headings.create!(name: I18n.t("seeds.geozones.central_district"),
                                     price: rand(5..10) * 100000,
                                     population: 150000)
  end

  Budget.all.each do |budget|
    budget.phases.all.each do |phase|
      enabled = true
      summary = "#{phase.kind.capitalize} summary should not be that long."
      presentation_summary_accepting = "#{phase.kind.capitalize} presentation summary for accepting proposals should not be that long."
      presentation_summary_balloting = "#{phase.kind.capitalize} presentation summary for balloting should not be that long."
      presentation_summary_finished = "#{phase.kind.capitalize} presentation summary for finished budget should not be that long."
      description = "#{phase.kind.capitalize} description should be a bit longer and should probably
      mention some more details about each phase and sometimes you can go too much into details
      and completely forget about the limits."
      if PHASES_TO_DISABLE.include?(phase.kind)
        enabled = false
      end
      phase.update!(enabled: enabled, summary: summary, presentation_summary_accepting: presentation_summary_accepting,
      presentation_summary_balloting: presentation_summary_balloting, presentation_summary_finished: presentation_summary_finished,
        description: description)
    end
  end
end

## If you want to add investment, othervise we use blank slate.
=begin
section "Creating Investments" do
  tags = ActsAsTaggableOn::Tag.category.limit(10)
  100.times do
    heading = Budget.last.headings.all.sample

    investment = Budget::Investment.create!(
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: "Test investment",
      description: "<p>Test investmen description</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: %w{undecided unfeasible feasible feasible feasible feasible}.sample,
      unfeasibility_explanation: "Faker::Lorem.paragraph",
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(","),
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
      MapLocation.create(latitude: Setting["map_latitude"].to_f + rand(-10..10) / 100.to_f,
                         longitude: Setting["map_longitude"].to_f + rand(-10..10) / 100.to_f,
                         zoom: Setting["map_zoom"],
                         investment_id: investment.id)
    end
  end
end
=end
