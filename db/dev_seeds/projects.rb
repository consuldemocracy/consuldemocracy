def create_rand_project_with_phases!(project_state, random_number, number_phases=2)
  title = Faker::Lorem.sentence(word_count: 3).truncate(60)
  teaser = Faker::Lorem.sentence(word_count: 3)
  slug = project_state + "#{random_number}"
  content = "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>"

  project = Project.create!(title: title,
                            teaser: teaser,
                            content: content,
                            slug: slug,
                            created_at: rand((1.week.ago)..Time.current),
                            state: project_state)
  project.save!
  random_locales.map do |locale|
    Globalize.with_locale(locale) do
      project.title = "Title for locale #{locale}"
      project.teaser = "Teaser for locale #{locale}"
      project.content = "<p>Content for locale #{locale}</p>"
      project.save!
    end
  end

  number_phases.times do |index|
    title_short = Faker::Lorem.sentence(word_count: 3).truncate(60)
    subtitle = Faker::Lorem.sentence(word_count: 3).truncate(80)
    title = Faker::Lorem.sentence(word_count: 3)
    content = "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>"
    start_rand = 15*index
    end_rand = 7 *index

    phase = Project::Phase.create!(title: title,
                                  project: project,
                                  subtitle: subtitle,
                                  content: content,
                                  created_at: rand((1.week.ago)..Time.current),
                                  title_short: title_short,
                                  enabled: [true, false].sample,
                                  starts_at: start_rand.days.ago,
                                  ends_at: end_rand.days.ago)
    random_locales.map do |locale|
      Globalize.with_locale(locale) do
        phase.title = "Title for locale #{locale}"
        phase.title_short = "Short for locale #{locale}"
        phase.subtitle = "Subtitle for locale #{locale}"
        phase.content = "<p>Content for locale #{locale}</p>"
        phase.save!
      end
    end
  end
end

section "Creating Projects" do
  2.times do |index|
    create_rand_project_with_phases!('active', index)
  end
  2.times do |index|
    create_rand_project_with_phases!('archived', index*10)
  end
  1.times do |index|
    create_rand_project_with_phases!('draft', index *100)
  end
end