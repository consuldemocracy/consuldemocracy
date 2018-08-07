section "Creating banners" do
  Proposal.last(3).each do |proposal|
    title = Faker::Lorem.sentence(word_count = 3)
    description = Faker::Lorem.sentence(word_count = 12)
    target_url = Rails.application.routes.url_helpers.proposal_path(proposal)
    banner = Banner.create!(title: title,
                            description: description,
                            target_url: target_url,
                            post_started_at: rand((Time.current - 1.week)..(Time.current - 1.day)),
                            post_ended_at:   rand((Time.current - 1.day)..(Time.current + 1.week)),
                            created_at: rand((Time.current - 1.week)..Time.current))
  end
end

section "Creating web sections" do
  WebSection.create(name: 'homepage')
  WebSection.create(name: 'debates')
  WebSection.create(name: 'proposals')
  WebSection.create(name: 'budgets')
  WebSection.create(name: 'help_page')
end
