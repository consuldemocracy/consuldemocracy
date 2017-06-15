require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

print "Creating Settings"
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
Setting.create(key: 'telegram_handle', value: 'consul')
Setting.create(key: 'instagram_handle', value: 'consul')
Setting.create(key: 'blog_url', value: '/blog')
Setting.create(key: 'url', value: 'http://localhost:3000')
Setting.create(key: 'org_name', value: 'Consul')
Setting.create(key: 'place_name', value: 'City')
Setting.create(key: 'feature.debates', value: "true")
Setting.create(key: 'feature.polls', value: "true")
Setting.create(key: 'feature.spending_proposals', value: nil)
Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: nil)
Setting.create(key: 'feature.budgets', value: "true")
Setting.create(key: 'feature.twitter_login', value: "true")
Setting.create(key: 'feature.facebook_login', value: "true")
Setting.create(key: 'feature.google_login', value: "true")
Setting.create(key: 'feature.signature_sheets', value: "true")
Setting.create(key: 'feature.legislation', value: "true")
Setting.create(key: 'per_page_code_head', value: "")
Setting.create(key: 'per_page_code_body', value: "")
Setting.create(key: 'comments_body_max_length', value: '1000')
Setting.create(key: 'mailer_from_name', value: 'Consul')
Setting.create(key: 'mailer_from_address', value: 'noreply@consul.dev')
Setting.create(key: 'meta_description', value: 'Citizen Participation and Open Government Application')
Setting.create(key: 'meta_keywords', value: 'citizen participation, open government')
Setting.create(key: 'verification_offices_url', value: 'http://oficinas-atencion-ciudadano.url/')
Setting.create(key: 'min_age_to_participate', value: '16')
Setting.create(key: 'proposal_improvement_path', value: nil)

puts " ✅"
print "Creating Geozones"

Geozone.create(name: "city")
Geozone.create(name: "Existent District", census_code: "01")
('A'..'Z').each { |i| Geozone.create(name: "District #{i}", external_code: i.ord, census_code: i.ord) }

puts " ✅"
print "Creating Users"

def create_user(email, username = Faker::Name.name)
  pwd = '12345678'
  User.create!(
    username:               username,
    email:                  email,
    password:               pwd,
    password_confirmation:  pwd,
    confirmed_at:           Time.current,
    terms_of_service:       "1",
    gender:                 ['Male', 'Female'].sample,
    date_of_birth:          rand((Time.current - 80.years) .. (Time.current - 16.years)),
    public_activity:        (rand(1..100) > 30)
  )
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

poll_officer = create_user('poll_officer@consul.dev', 'Paul O. Fisher')
poll_officer.create_poll_officer

level_2 = create_user('leveltwo@consul.dev', 'level 2')
level_2.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: "2222222222", document_type: "1")

verified = create_user('verified@consul.dev', 'verified')
verified.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

(1..10).each do |i|
  org_name = Faker::Company.name
  org_user = create_user("org#{i}@consul.dev", org_name)
  org_responsible_name = Faker::Name.name
  org = org_user.create_organization(name: org_name, responsible_name: org_responsible_name)

  verified = [true, false].sample
  if verified
    org.verify
  else
    org.reject
  end
end

(1..5).each do |i|
  official = create_user("official#{i}@consul.dev")
  official.update(official_level: i, official_position: "Official position #{i}")
end

(1..100).each do |i|
  user = create_user("user#{i}@consul.dev")
  level = [1, 2, 3].sample
  if level >= 2
    user.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: Faker::Number.number(10), document_type: "1", geozone:  Geozone.reorder("RANDOM()").first)
  end
  if level == 3
    user.update(verified_at: Time.current, document_number: Faker::Number.number(10))
  end
end

org_user_ids = User.organizations.pluck(:id)
not_org_users = User.where(['users.id NOT IN(?)', org_user_ids])

puts " ✅"
print "Creating Tags Categories"

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
ActsAsTaggableOn::Tag.create!(name:  "Salud", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Transparencia", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Seguridad y Emergencias", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Medio Ambiente", featured: true, kind: "category")

puts " ✅"
print "Creating Debates"

tags = Faker::Lorem.words(25)
30.times do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3).truncate(60),
                          created_at: rand((Time.current - 1.week)..Time.current),
                          description: description,
                          tag_list: tags.sample(3).join(','),
                          geozone: Geozone.reorder("RANDOM()").first,
                          terms_of_service: "1")
end

tags = ActsAsTaggableOn::Tag.where(kind: 'category')
30.times do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3).truncate(60),
                          created_at: rand((Time.current - 1.week)..Time.current),
                          description: description,
                          tag_list: tags.sample(3).join(','),
                          geozone: Geozone.reorder("RANDOM()").first,
                          terms_of_service: "1")
end

puts " ✅"
print "Creating Proposals"

tags = Faker::Lorem.words(25)
30.times do
  author = User.reorder("RANDOM()").first
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
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1")
end

puts " ✅"
print "Creating Archived Proposals"

tags = Faker::Lorem.words(25)
5.times do
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3) + "?",
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1",
                              created_at: Setting["months_to_archive_proposals"].to_i.months.ago)
end

puts " ✅"
print "Creating Successful Proposals"

tags = Faker::Lorem.words(25)
10.times do
  author = User.reorder("RANDOM()").first
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
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1",
                              cached_votes_up: Setting["votes_for_proposal_success"])
end

tags = ActsAsTaggableOn::Tag.where(kind: 'category')
30.times do
  author = User.reorder("RANDOM()").first
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
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1")
end

puts " ✅"
print "Commenting Debates"

100.times do
  author = User.reorder("RANDOM()").first
  debate = Debate.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(debate.created_at..Time.current),
                  commentable: debate,
                  body: Faker::Lorem.sentence)
end

puts " ✅"
print "Commenting Proposals"

100.times do
  author = User.reorder("RANDOM()").first
  proposal = Proposal.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(proposal.created_at..Time.current),
                  commentable: proposal,
                  body: Faker::Lorem.sentence)
end

puts " ✅"
print "Commenting Comments"

200.times do
  author = User.reorder("RANDOM()").first
  parent = Comment.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(parent.created_at..Time.current),
                  commentable_id: parent.commentable_id,
                  commentable_type: parent.commentable_type,
                  body: Faker::Lorem.sentence,
                  parent: parent)
end

puts " ✅"
print "Voting Debates, Proposals & Comments"

100.times do
  voter  = not_org_users.level_two_or_three_verified.reorder("RANDOM()").first
  vote   = [true, false].sample
  debate = Debate.reorder("RANDOM()").first
  debate.vote_by(voter: voter, vote: vote)
end

100.times do
  voter  = not_org_users.reorder("RANDOM()").first
  vote   = [true, false].sample
  comment = Comment.reorder("RANDOM()").first
  comment.vote_by(voter: voter, vote: vote)
end

100.times do
  voter  = not_org_users.level_two_or_three_verified.reorder("RANDOM()").first
  proposal = Proposal.reorder("RANDOM()").first
  proposal.vote_by(voter: voter, vote: true)
end

puts " ✅"
print "Flagging Debates & Comments"

40.times do
  debate = Debate.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", debate.author_id]).reorder("RANDOM()").first
  Flag.flag(flagger, debate)
end

40.times do
  comment = Comment.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", comment.user_id]).reorder("RANDOM()").first
  Flag.flag(flagger, comment)
end

40.times do
  proposal = Proposal.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", proposal.author_id]).reorder("RANDOM()").first
  Flag.flag(flagger, proposal)
end

puts " ✅"
print "Creating Spending Proposals"

tags = Faker::Lorem.words(10)

60.times do
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
                                               created_at: rand((Time.current - 1.week)..Time.current),
                                               geozone: [geozone, nil].sample,
                                               feasible: feasible,
                                               feasible_explanation: feasible_explanation,
                                               valuation_finished: valuation_finished,
                                               tag_list: tags.sample(3).join(','),
                                               price: rand(1000000),
                                               terms_of_service: "1")
end

puts " ✅"
print "Creating Valuation Assignments"

(1..17).to_a.sample.times do
  SpendingProposal.reorder("RANDOM()").first.valuators << valuator.valuator
end

puts " ✅"
print "Creating Budgets"

Budget::PHASES.each_with_index do |phase, i|
  descriptions = Hash[Budget::PHASES.map do |p|
    ["description_#{p}",
     "<p>#{Faker::Lorem.paragraphs(2).join('</p><p>')}</p>"]
  end]
  budget = Budget.create!(
    descriptions.merge(
      name: (Date.current - 10 + i).to_s,
      currency_symbol: "€",
      phase: phase
    )
  )

  (1..([1, 2, 3].sample)).each do
    group = budget.groups.create!(name: Faker::StarWars.planet)

    geozones = Geozone.reorder("RANDOM()").limit([2, 5, 6, 7].sample)
    geozones.each do |geozone|
      group.headings << group.headings.create!(name: geozone.name,
                                               price: rand(1..100) * 100000)
    end
  end
end

puts " ✅"
print "Creating Investments"
tags = Faker::Lorem.words(10)
100.times do
  heading = Budget::Heading.reorder("RANDOM()").first

  investment = Budget::Investment.create!(
    author: User.reorder("RANDOM()").first,
    heading: heading,
    group: heading.group,
    budget: heading.group.budget,
    title: Faker::Lorem.sentence(3).truncate(60),
    external_url: Faker::Internet.url,
    description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
    created_at: rand((Time.current - 1.week)..Time.current),
    feasibility: %w{undecided unfeasible feasible feasible feasible feasible}.sample,
    unfeasibility_explanation: Faker::Lorem.paragraph,
    valuation_finished: [false, true].sample,
    tag_list: tags.sample(3).join(','),
    price: rand(1..100) * 100000,
    terms_of_service: "1"
  )
end

puts " ✅"
print "Balloting Investments"
Budget.balloting.last.investments.each do |investment|
  investment.update(selected: true, feasibility: "feasible")
end

puts " ✅"
print "Winner Investments"

budget = Budget.where(phase: "finished").last
100.times do
  heading = budget.headings.reorder("RANDOM()").first
  investment = Budget::Investment.create!(
    author: User.reorder("RANDOM()").first,
    heading: heading,
    group: heading.group,
    budget: heading.group.budget,
    title: Faker::Lorem.sentence(3).truncate(60),
    external_url: Faker::Internet.url,
    description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
    created_at: rand((Time.current - 1.week)..Time.current),
    feasibility: "feasible",
    valuation_finished: true,
    selected: true,
    price: rand(10000..heading.price),
    terms_of_service: "1"
  )
end
budget.headings.each do |heading|
  Budget::Result.new(budget, heading).calculate_winners
end

puts " ✅"
print "Creating Valuation Assignments"

(1..50).to_a.sample.times do
  Budget::Investment.reorder("RANDOM()").first.valuators << valuator.valuator
end

puts " ✅"
print "Ignoring flags in Debates, comments & proposals"

Debate.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
Comment.flagged.reorder("RANDOM()").limit(30).each(&:ignore_flag)
Proposal.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)

puts " ✅"
print "Hiding debates, comments & proposals"

Comment.with_hidden.flagged.reorder("RANDOM()").limit(30).each(&:hide)
Debate.with_hidden.flagged.reorder("RANDOM()").limit(5).each(&:hide)
Proposal.with_hidden.flagged.reorder("RANDOM()").limit(10).each(&:hide)

puts " ✅"
print "Confirming hiding in debates, comments & proposals"

Comment.only_hidden.flagged.reorder("RANDOM()").limit(10).each(&:confirm_hide)
Debate.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)
Proposal.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)

puts " ✅"
print "Creating banners"

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
                          post_started_at: rand((Time.current - 1.week)..(Time.current - 1.day)),
                          post_ended_at:   rand((Time.current  - 1.day)..(Time.current + 1.week)),
                          created_at: rand((Time.current - 1.week)..Time.current))
end

puts " ✅"
puts "Creating proposal notifications"

100.times do |i|
  ProposalNotification.create!(title: "Proposal notification title #{i}",
                               body: "Proposal notification body #{i}",
                               author: User.reorder("RANDOM()").first,
                               proposal: Proposal.reorder("RANDOM()").first)
end

puts " ✅"
print "Creating polls"

puts " ✅"
print "Active Polls"
(1..3).each do |i|
  poll = Poll.create(name: "Active Poll #{i}",
                     starts_at: 1.month.ago,
                     ends_at:   1.month.from_now,
                     geozone_restricted: false)
end
(1..5).each do |i|
  poll = Poll.create(name: "Active Poll #{i}",
                     starts_at: 1.month.ago,
                     ends_at:   1.month.from_now,
                     geozone_restricted: true,
                     geozones: Geozone.reorder("RANDOM()").limit(3))
end

puts " ✅"
print "Upcoming Poll"
poll = Poll.create(name: "Upcoming Poll",
                   starts_at: 1.month.from_now,
                   ends_at:   2.months.from_now)

puts " ✅"
print "Expired Poll"
poll = Poll.create(name: "Expired Poll",
                   starts_at: 2.months.ago,
                   ends_at:   1.month.ago)

puts " ✅"
print "Creating Poll Questions"

50.times do
  poll = Poll.reorder("RANDOM()").first
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  open_at = rand(2.months.ago..2.months.from_now)
  question = Poll::Question.create!(author: author,
                                    title: Faker::Lorem.sentence(3).truncate(60),
                                    description: description,
                                    valid_answers: Faker::Lorem.words((2..7).to_a.sample).join(', '),
                                    poll: poll)
end

puts " ✅"
print "Creating Poll Booths"
30.times.each_with_index do |i|
  Poll::Booth.create(name: "Booth #{i}", polls: [Poll.all.sample])
end

puts " ✅"
print "Creating Booth Assignments"
Poll::Booth.all.each do |booth|
  Poll::BoothAssignment.create(booth: booth, poll: Poll.all.sample)
end

puts " ✅"
print "Creating Poll Officer Assignments"
(1..15).to_a.sample.times do |i|
  Poll::BoothAssignment.all.sample(i).each do |booth_assignment|
    Poll::OfficerAssignment.create(officer: poll_officer.poll_officer,
                                   booth_assignment: booth_assignment,
                                   date: booth_assignment.poll.starts_at)
  end
end

puts " ✅"
print "Creating Poll Recounts" do
  (1..15).to_a.sample.times do |i|
    poll_officer.poll_officer.officer_assignments.all.sample(i).each do |officer_assignment|
      Poll::Recount.create(officer_assignment: officer_assignment,
                           booth_assignment: officer_assignment.booth_assignment,
                           date: officer_assignment.date,
                           count: (1..5000).to_a.sample)
    end
  end

end

puts " ✅"
print "Creating Poll Questions from Proposals"

3.times do
  proposal = Proposal.reorder("RANDOM()").first
  poll = Poll.current.first
  question = Poll::Question.create(valid_answers: "Yes, No")
  question.copy_attributes_from_proposal(proposal)
  question.save!
end

puts " ✅"
print "Creating Successful Proposals"

10.times do
  proposal = Proposal.reorder("RANDOM()").first
  poll = Poll.current.first
  question = Poll::Question.create(valid_answers: "Yes, No")
  question.copy_attributes_from_proposal(proposal)
  question.save!
end

puts " ✅"
print "Commenting Poll Questions"

30.times do
  author = User.reorder("RANDOM()").first
  question = Poll::Question.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(question.created_at..Time.current),
                  commentable: question,
                  body: Faker::Lorem.sentence)
end

puts " ✅"
print "Creating Poll Voters"

10.times do
  poll = Poll.all.sample
  user = User.level_two_verified.sample
  Poll::Voter.create(poll: poll, user: user)
end

puts " ✅"
print "Creating legislation processes"

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
                                           result_publication_enabled: true
  )
end

::Legislation::Process.all.each do |process|
  (1..3).each do |i|
    version = process.draft_versions.create!(title: "Version #{i}",
                                             body: Faker::Lorem.paragraphs.join("\n\n"))
  end
end

puts " ✅"
puts "All dev seeds created successfuly 👍"
