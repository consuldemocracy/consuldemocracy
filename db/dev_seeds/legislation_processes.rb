section "Creating legislation processes" do
  5.times do
    process = ::Legislation::Process.create!(title: Faker::Lorem.sentence(3).truncate(60),
                                             description: Faker::Lorem.paragraphs.join("\n\n"),
                                             summary: Faker::Lorem.paragraph,
                                             additional_info: Faker::Lorem.paragraphs.join("\n\n"),
                                             start_date: Date.current - 3.days,
                                             end_date: Date.current + 3.days,
                                             debate_start_date: Date.current - 3.days,
                                             debate_end_date: Date.current - 1.day,
                                             draft_publication_date: Date.current + 1.day,
                                             allegations_start_date: Date.current + 2.days,
                                             allegations_end_date: Date.current + 3.days,
                                             result_publication_date: Date.current + 4.days,
                                             debate_phase_enabled: true,
                                             allegations_phase_enabled: true,
                                             draft_publication_enabled: true,
                                             result_publication_enabled: true,
                                             published: true)
  end

  ::Legislation::Process.all.each do |process|
    (1..3).each do |i|
      version = process.draft_versions.create!(title: "Version #{i}",
                                               body: Faker::Lorem.paragraphs.join("\n\n"))
    end
  end
end
