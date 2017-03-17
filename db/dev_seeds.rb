require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

puts "Creating Settings"
Setting.create(key: 'official_level_1_name', value: 'Empleados públicos')
Setting.create(key: 'official_level_2_name', value: 'Organización Municipal')
Setting.create(key: 'official_level_3_name', value: 'Directores generales')
Setting.create(key: 'official_level_4_name', value: 'Concejales')
Setting.create(key: 'official_level_5_name', value: 'Alcaldesa')
Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')
Setting.create(key: 'max_votes_for_debate_edit', value: '1000')
Setting.create(key: 'max_votes_for_proposal_edit', value: '1000')
Setting.create(key: 'proposal_code_prefix', value: 'MAD')
Setting.create(key: 'votes_for_proposal_success', value: '100')
Setting.create(key: 'months_to_archive_proposals', value: '12')
Setting.create(key: 'comments_body_max_length', value: '1000')

Setting.create(key: 'twitter_handle', value: '@consul_dev')
Setting.create(key: 'twitter_hashtag', value: '#consul_dev')
Setting.create(key: 'facebook_handle', value: 'consul')
Setting.create(key: 'youtube_handle', value: 'consul')
Setting.create(key: 'blog_url', value: '/blog')
Setting.create(key: 'url', value: 'http://localhost:3000')
Setting.create(key: 'org_name', value: 'Consul')
Setting.create(key: 'place_name', value: 'City')
Setting.create(key: 'feature.debates', value: "true")
Setting.create(key: 'feature.spending_proposals', value: nil)
Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: nil)
Setting.create(key: 'feature.budgets', value: "true")
Setting.create(key: 'feature.twitter_login', value: "true")
Setting.create(key: 'feature.facebook_login', value: "true")
Setting.create(key: 'feature.google_login', value: "true")
Setting.create(key: 'feature.signature_sheets', value: "true")
Setting.create(key: 'per_page_code_head', value: "")
Setting.create(key: 'per_page_code_body', value: "")
Setting.create(key: 'comments_body_max_length', value: '1000')
Setting.create(key: 'mailer_from_name', value: 'Consul')
Setting.create(key: 'mailer_from_address', value: 'noreply@consul.dev')
Setting.create(key: 'meta_description', value: 'Citizen Participation and Open Government Application')
Setting.create(key: 'meta_keywords', value: 'citizen participation, open government')
Setting.create(key: 'verification_offices_url', value: 'http://oficinas-atencion-ciudadano.url/')
Setting.create(key: 'min_age_to_participate', value: '16')

puts "Creating Geozones"
('A'..'Z').each { |i| Geozone.create(name: "District #{i}", external_code: i.ord, census_code: i.ord) }

puts "Creating Users"

def create_user(email, username = Faker::Name.name)
  pwd = '12345678'
  puts "    #{username}"
  User.create!(username: username, email: email, password: pwd, password_confirmation: pwd, confirmed_at: Time.current, terms_of_service: "1")
end

admin = create_user('admin@consul.dev', 'admin')
admin.create_administrator
admin.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "1111111111")

moderator = create_user('mod@consul.dev', 'mod')
moderator.create_moderator

manager = create_user('manager@consul.dev', 'manager')
manager.create_manager

valuator = create_user('valuator@consul.dev', 'valuator')
valuator.create_valuator

level_2 = create_user('leveltwo@consul.dev', 'level 2')
level_2.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: "2222222222", document_type: "1" )

verified = create_user('verified@consul.dev', 'verified')
verified.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

(1..10).each do |i|
  org_name = Faker::Company.name
  org_user = create_user("org#{i}@consul.dev", org_name)
  org_responsible_name = Faker::Name.name
  org = org_user.create_organization(name: org_name, responsible_name: org_responsible_name)

  verified = [true, false].sample
  if verified then
    org.verify
  else
    org.reject
  end
end

(1..5).each do |i|
  official = create_user("official#{i}@consul.dev")
  official.update(official_level: i, official_position: "Official position #{i}")
end

(1..40).each do |i|
  user = create_user("user#{i}@consul.dev")
  level = [1, 2, 3].sample
  if level >= 2
    user.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: Faker::Number.number(10), document_type: "1" )
  end
  if level == 3
    user.update(verified_at: Time.current, document_number: Faker::Number.number(10) )
  end
end

org_user_ids = User.organizations.pluck(:id)
not_org_users = User.where(['users.id NOT IN(?)', org_user_ids])

puts "Creating Tags Categories"

ActsAsTaggableOn::Tag.create!(name:  "Asociaciones", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Cultura", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Deportes", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Derechos Sociales", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Economía", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Empleo", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Equidad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Sostenibilidad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Participación", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Movilidad", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Medios", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Salud", featured: true , kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Transparencia", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Seguridad y Emergencias", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Medio Ambiente", featured: true, kind: "category")

puts "Creating Debates"

tags = Faker::Lorem.words(25)
(1..30).each do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3).truncate(60),
                          created_at: rand((Time.current - 1.week) .. Time.current),
                          description: description,
                          tag_list: tags.sample(3).join(','),
                          geozone: Geozone.reorder("RANDOM()").first,
                          terms_of_service: "1")
  puts "    #{debate.title}"
end


tags = ActsAsTaggableOn::Tag.where(kind: 'category')
(1..30).each do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3).truncate(60),
                          created_at: rand((Time.current - 1.week) .. Time.current),
                          description: description,
                          tag_list: tags.sample(3).join(','),
                          geozone: Geozone.reorder("RANDOM()").first,
                          terms_of_service: "1")
  puts "    #{debate.title}"
end


puts "Creating Proposals"

tags = Faker::Lorem.words(25)
(1..30).each do |i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3) + "?",
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.current - 1.week) .. Time.current),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1")
  puts "    #{proposal.title}"
end

puts "Creating Archived Proposals"

tags = Faker::Lorem.words(25)
(1..5).each do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3) + "?",
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.current - 1.week) .. Time.current),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1",
                              created_at: Setting["months_to_archive_proposals"].to_i.months.ago)
  puts "    #{proposal.title}"
end


tags = ActsAsTaggableOn::Tag.where(kind: 'category')
(1..30).each do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3) + "?",
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.current - 1.week) .. Time.current),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1")
  puts "    #{proposal.title}"
end


puts "Commenting Debates"

(1..100).each do
  author = User.reorder("RANDOM()").first
  debate = Debate.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(debate.created_at .. Time.current),
                  commentable: debate,
                  body: Faker::Lorem.sentence)
end


puts "Commenting Proposals"

(1..100).each do |i|
  author = User.reorder("RANDOM()").first
  proposal = Proposal.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(proposal.created_at .. Time.current),
                  commentable: proposal,
                  body: Faker::Lorem.sentence)
end


puts "Commenting Comments"

(1..200).each do
  author = User.reorder("RANDOM()").first
  parent = Comment.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(parent.created_at .. Time.current),
                  commentable_id: parent.commentable_id,
                  commentable_type: parent.commentable_type,
                  body: Faker::Lorem.sentence,
                  parent: parent)
end


puts "Voting Debates, Proposals & Comments"

(1..100).each do
  voter  = not_org_users.reorder("RANDOM()").first
  vote   = [true, false].sample
  debate = Debate.reorder("RANDOM()").first
  debate.vote_by(voter: voter, vote: vote)
end

(1..100).each do |i|
  voter  = not_org_users.reorder("RANDOM()").first
  vote   = [true, false].sample
  comment = Comment.reorder("RANDOM()").first
  comment.vote_by(voter: voter, vote: vote)
end

(1..100).each do
  voter  = User.level_two_or_three_verified.reorder("RANDOM()").first
  proposal = Proposal.reorder("RANDOM()").first
  proposal.vote_by(voter: voter, vote: true)
end


puts "Flagging Debates & Comments"

(1..40).each do
  debate = Debate.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", debate.author_id]).reorder("RANDOM()").first
  Flag.flag(flagger, debate)
end

(1..40).each do
  comment = Comment.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", comment.user_id]).reorder("RANDOM()").first
  Flag.flag(flagger, comment)
end

(1..40).each do
  proposal = Proposal.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", proposal.author_id]).reorder("RANDOM()").first
  Flag.flag(flagger, proposal)
end

puts "Creating Spending Proposals"

tags = Faker::Lorem.words(10)

(1..60).each do
  geozone = Geozone.reorder("RANDOM()").first
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  feasible_explanation = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  valuation_finished = [true, false].sample
  feasible = [true, false].sample
  spending_proposal = SpendingProposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.current - 1.week) .. Time.current),
                              geozone: [geozone, nil].sample,
                              feasible: feasible,
                              feasible_explanation: feasible_explanation,
                              valuation_finished: valuation_finished,
                              tag_list: tags.sample(3).join(','),
                              price: rand(1000000),
                              terms_of_service: "1")
  puts "    #{spending_proposal.title}"
end

puts "Creating Valuation Assignments"

(1..17).to_a.sample.times do
  SpendingProposal.reorder("RANDOM()").first.valuators << valuator.valuator
end


puts "Creating Budgets"

Budget::PHASES.each_with_index do |phase, i|
  descriptions = Hash[Budget::PHASES.map{ |p| ["description_#{p}",
                                               "<p>#{Faker::Lorem.paragraphs(2).join('</p><p>')}</p>"] }]
  budget = Budget.create!(
    descriptions.merge(
      name: (Date.current - 10 + i).to_s,
      currency_symbol: "€",
      phase: phase
    )
  )

  puts budget.name

  (1..([1, 2, 3].sample)).each do
    group = budget.groups.create!(name: Faker::StarWars.planet)

    geozones = Geozone.reorder("RANDOM()").limit([2, 5, 6, 7].sample)
    geozones.each do |geozone|
      group.headings << group.headings.create!(name: geozone.name,
                                               #geozone: geozone,
                                               price: rand(1 .. 100) * 100000)

    end
    print "#{group.name} "
  end
  puts ""
end


puts "Creating Investments"
tags = Faker::Lorem.words(10)
(1..100).each do |i|
  heading = Budget::Heading.reorder("RANDOM()").first

  investment = Budget::Investment.create!(
    author: User.reorder("RANDOM()").first,
    heading: heading,
    group: heading.group,
    budget: heading.group.budget,
    title: Faker::Lorem.sentence(3).truncate(60),
    external_url: Faker::Internet.url,
    description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
    created_at: rand((Time.now - 1.week) .. Time.now),
    feasibility: %w{undecided unfeasible feasible feasible feasible feasible}.sample,
    unfeasibility_explanation: Faker::Lorem.paragraph,
    valuation_finished: [false, true].sample,
    tag_list: tags.sample(3).join(','),
    price: rand(1 .. 100) * 100000,
    terms_of_service: "1")
  puts "    #{investment.title}"
end

puts "Selecting Investments"
Budget.balloting.reorder("RANDOM()").limit(3).each do |budget|
  budget.investments.feasible.reorder("RANDOM()").limit(10).update_all(selected: true)
end

puts "Creating Valuation Assignments"

(1..17).to_a.sample.times do
  Budget::Investment.reorder("RANDOM()").first.valuators << valuator.valuator
end


puts "Creating Legislation"

Legislation.create!(title: 'Participatory Democracy', body: 'In order to achieve...')


puts "Ignoring flags in Debates, comments & proposals"

Debate.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
Comment.flagged.reorder("RANDOM()").limit(30).each(&:ignore_flag)
Proposal.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)


puts "Hiding debates, comments & proposals"

Comment.with_hidden.flagged.reorder("RANDOM()").limit(30).each(&:hide)
Debate.with_hidden.flagged.reorder("RANDOM()").limit(5).each(&:hide)
Proposal.with_hidden.flagged.reorder("RANDOM()").limit(10).each(&:hide)


puts "Confirming hiding in debates, comments & proposals"

Comment.only_hidden.flagged.reorder("RANDOM()").limit(10).each(&:confirm_hide)
Debate.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)
Proposal.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)

puts "Creating banners"

Proposal.last(3).each do |proposal|
  title = Faker::Lorem.sentence(word_count = 3)
  description = Faker::Lorem.sentence(word_count = 12)
  banner = Banner.create!(title: title,
                          description: description,
                          style: ["banner-style banner-style-one", "banner-style banner-style-two",
                                  "banner-style banner-style-three"].sample,
                          image: ["banner-img banner-img-one", "banner-img banner-img-two",
                                  "banner-img banner-img-three"].sample,
                          target_url: Rails.application.routes.url_helpers.proposal_path(proposal),
                          post_started_at: rand((Time.current - 1.week) .. (Time.current - 1.day)),
                          post_ended_at:   rand((Time.current  - 1.day) .. (Time.current + 1.week)),
                          created_at: rand((Time.current - 1.week) .. Time.current))
  puts "    #{banner.title}"
end
