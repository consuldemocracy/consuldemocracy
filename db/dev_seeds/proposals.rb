IMAGE_FILES = %w{
  firdouss-ross-414668-unsplash_846x475.jpg
  nathan-dumlao-496190-unsplash_713x475.jpg
  steve-harvey-597760-unsplash_713x475.jpg
  tim-mossholder-302931-unsplash_713x475.jpg
}.map do |filename|
  File.new(Rails.root.join("db",
                           "dev_seeds",
                           "images",
                           "proposals", filename))
end

def add_image_to(imageable)
  # imageable should respond to #title & #author
  imageable.image = Image.create!({
    imageable: imageable,
    title: imageable.title,
    attachment: IMAGE_FILES.sample,
    user: imageable.author
  })
  imageable.save
end

section "Creating Proposals" do
  tags = Faker::Lorem.words(25)
  30.times do
    title = Faker::Lorem.sentence(3).truncate(60)
    question = Faker::Lorem.sentence(3) + "?"
    summary = Faker::Lorem.sentence(3)
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    author = User.all.sample

    proposal = Proposal.create!(author: author,
                                title: title,
                                question: question,
                                summary: summary,
                                description: description,
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                created_at: rand((Time.current - 1.week)..Time.current),
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                skip_map: "1",
                                terms_of_service: "1")
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        proposal.title = "Title for locale #{locale}"
        proposal.question = "Question for locale #{locale}?"
        proposal.summary = "Summary for locale #{locale}"
        proposal.description = "<p>Description for locale #{locale}</p>"
        proposal.save!
      end
    end
    add_image_to proposal
  end
end

section "Creating Archived Proposals" do
  tags = Faker::Lorem.words(25)
  5.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                question: Faker::Lorem.sentence(3) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                skip_map: "1",
                                terms_of_service: "1",
                                created_at: Setting["months_to_archive_proposals"].to_i.months.ago)
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        proposal.title = "Archived proposal title for locale #{locale}"
        proposal.question = "Archived proposal question for locale #{locale}?"
        proposal.summary = "Archived proposal title summary for locale #{locale}"
        proposal.description = "<p>Archived proposal description for locale #{locale}</p>"
        proposal.save!
      end
    end
    add_image_to proposal
  end
end

section "Creating Successful Proposals" do
  tags = Faker::Lorem.words(25)
  10.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                question: Faker::Lorem.sentence(3) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                created_at: rand((Time.current - 1.week)..Time.current),
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                skip_map: "1",
                                terms_of_service: "1",
                                cached_votes_up: Setting["votes_for_proposal_success"])
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        proposal.title = "Successful proposal title for locale #{locale}"
        proposal.question = "Successful proposal question for locale #{locale}?"
        proposal.summary = "Successful proposal title summary for locale #{locale}"
        proposal.description = "<p>Successful proposal description for locale #{locale}</p>"
        proposal.save!
      end
    end
    add_image_to proposal
  end

  tags = ActsAsTaggableOn::Tag.where(kind: 'category')
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(4).truncate(60),
                                question: Faker::Lorem.sentence(6) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                created_at: rand((Time.current - 1.week)..Time.current),
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                skip_map: "1",
                                terms_of_service: "1")
    I18n.available_locales.map do |locale|
      Globalize.with_locale(locale) do
        proposal.title = "Tagged proposal title for locale #{locale}"
        proposal.question = "Tagged proposal question for locale #{locale}?"
        proposal.summary = "Tagged proposal title summary for locale #{locale}"
        proposal.description = "<p>Tagged proposal description for locale #{locale}</p>"
        proposal.save!
      end
    end
    add_image_to proposal
  end
end

section "Creating proposal notifications" do
  100.times do |i|
    ProposalNotification.create!(title: "Proposal notification title #{i}",
                                 body: "Proposal notification body #{i}",
                                 author: User.all.sample,
                                 proposal: Proposal.all.sample)
  end
end
