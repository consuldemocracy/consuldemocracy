section "Creating banners" do
  Proposal.last(3).each do |proposal|
    title = Faker::Lorem.sentence(3)
    description = Faker::Lorem.sentence(12)
    target_url = Rails.application.routes.url_helpers.proposal_path(proposal)
    banner = Banner.new(title: title,
                        description: description,
                        target_url: target_url,
                        post_started_at: rand((Time.current - 1.week)..(Time.current - 1.day)),
                        post_ended_at:   rand((Time.current - 1.day)..(Time.current + 1.week)),
                        created_at: rand((Time.current - 1.week)..Time.current))
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        banner.description = "Description for locale #{locale}"
        banner.title = "Title for locale #{locale}"
        banner.save!
      end
    end
  end
end

load Rails.root.join("db", "web_sections.rb")
