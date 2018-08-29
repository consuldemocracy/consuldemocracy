section "Creating legislation processes" do
  5.times do
    Legislation::Process.create!(title: Faker::Lorem.sentence(3).truncate(60),
                                 description: Faker::Lorem.paragraphs.join("\n\n"),
                                 summary: Faker::Lorem.paragraph,
                                 additional_info: Faker::Lorem.paragraphs.join("\n\n"),
                                 proposals_description: Faker::Lorem.paragraph,
                                 start_date: Date.current - 3.days,
                                 end_date: Date.current + 3.days,
                                 debate_start_date: Date.current - 3.days,
                                 debate_end_date: Date.current - 1.day,
                                 proposals_phase_start_date: Date.current - 3.days,
                                 proposals_phase_end_date: Date.current - 1.day,
                                 draft_publication_date: Date.current + 1.day,
                                 allegations_start_date: Date.current + 2.days,
                                 allegations_end_date: Date.current + 3.days,
                                 result_publication_date: Date.current + 4.days,
                                 debate_phase_enabled: true,
                                 allegations_phase_enabled: true,
                                 draft_publication_enabled: true,
                                 result_publication_enabled: true,
                                 proposals_phase_enabled: true,
                                 published: true)
  end

  Legislation::Process.find_each do |process|
    (1..3).each do |i|
      process.draft_versions.create!(title_en: "Version #{i}",
                                     title_es: "Versión #{i}",
                                     body_en: ["Draft version in English",
                                               *Faker::Lorem.paragraphs].join("\n\n"),
                                     body_es: ["Versión borrador en Español",
                                               *Faker::Lorem.paragraphs].join("\n\n"))
    end
  end
end
