section "Creating Sustainable Development Goals" do
  load Rails.root.join("db", "sdg.rb")

  SDG::Target.sample(30).each do |target|
    title = "Title for default locale"
    description = "Description for default locale"
    rand(2..3).times do |n|
      local_target = SDG::LocalTarget.create!(code: "#{target.code}.#{n + 1}",
                                              title: title,
                                              description: description,
                                              target: target)
      random_locales.map do |locale|
        Globalize.with_locale(locale) do
          local_target.title = "Title for locale #{locale}"
          local_target.description = "Description for locale #{locale}"
          local_target.save!
        end
      end
    end
  end

  relatables = [Debate, Proposal, Poll, Legislation::Process, Budget::Investment]
  relatables.map { |relatable| relatable.sample(5) }.flatten.each do |relatable|
    Array(SDG::Goal.sample(rand(1..3))).each do |goal|
      target = goal.targets.sample
      local_target = target.local_targets.sample
      relatable.sdg_goals << goal
      relatable.sdg_targets << target
      relatable.sdg_local_targets << local_target if local_target.present?
    end
  end
end

section "Creating SDG homepage cards" do
  SDG::Phase.all.each do |phase|
    Widget::Card.create!(cardable: phase, title: "#{phase.title} card")
  end
end
