require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

print "Creating Settings"
Setting["email_domain_for_officials"] = 'madrid.es'
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

Setting.create(key: 'twitter_handle', value: '@decidemadrid')
Setting.create(key: 'twitter_hashtag', value: '#decidemadrid')
Setting.create(key: 'facebook_handle', value: 'decidemadrid')
Setting.create(key: 'youtube_handle', value: 'decidemadrid')
Setting.create(key: 'telegram_handle', value: 'decidemadrid')
Setting.create(key: 'instagram_handle', value: 'decidemadrid')
Setting.create(key: 'blog_url', value: 'https://diario.madrid.es/decidemadrid/')
Setting.create(key: 'url', value: 'http://localhost:3000')
Setting.create(key: 'org_name', value: 'Decide Madrid')
Setting.create(key: 'place_name', value: 'City')

Setting.create(key: 'feature.debates', value: "true")

Setting.create(key: 'feature.polls', value: "true")

Setting.create(key: 'feature.spending_proposals', value: nil)
Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: nil)
Setting.create(key: 'feature.spending_proposal_features.phase1', value: nil)
Setting.create(key: 'feature.spending_proposal_features.phase2', value: nil)
Setting.create(key: 'feature.spending_proposal_features.phase3', value: "true")
Setting.create(key: 'feature.spending_proposal_features.final_voting_allowed', value: "true")
Setting.create(key: 'feature.spending_proposal_features.open_results_page', value: nil)

Setting.create(key: 'feature.budgets', value: "true")
Setting.create(key: 'feature.twitter_login', value: "true")
Setting.create(key: 'feature.facebook_login', value: "true")
Setting.create(key: 'feature.google_login', value: "true")
Setting.create(key: 'feature.probe.plaza', value: 'true')
Setting.create(key: 'feature.human_rights.accepting', value: 'true')
Setting.create(key: 'feature.human_rights.voting', value: 'true')
Setting.create(key: 'feature.human_rights.closed', value: 'true')
Setting.create(key: 'feature.signature_sheets', value: "true")
Setting.create(key: 'feature.legislation', value: "true")
Setting.create(key: 'feature.user.recommendations', value: "true")
Setting.create(key: 'feature.community', value: "true")
Setting.create(key: 'feature.map', value: "true")
Setting.create(key: 'feature.allow_images', value: "true")

Setting.create(key: 'per_page_code_head', value: "")
Setting.create(key: 'per_page_code_body', value: "")
Setting.create(key: 'comments_body_max_length', value: '1000')
Setting.create(key: 'mailer_from_name', value: 'Decide Madrid')
Setting.create(key: 'mailer_from_address', value: 'noreply@madrid.es')
Setting.create(key: 'meta_description', value: 'Citizen Participation and Open Government Application')
Setting.create(key: 'meta_keywords', value: 'citizen participation, open government')
Setting.create(key: 'verification_offices_url', value: 'http://oficinas-atencion-ciudadano.url/')
Setting.create(key: 'min_age_to_participate', value: '16')
Setting.create(key: 'proposal_improvement_path', value: nil)
Setting.create(key: 'map_latitude', value: 51.48)
Setting.create(key: 'map_longitude', value: 0.0)
Setting.create(key: 'map_zoom', value: 10)

# piwik_tracking_code_head = "<!-- Piwik -->
# <script type='text/javascript'>
#   var _paq = _paq || [];
#   _paq.push(['setDomains', ['*.decidedesa.madrid.es']]);
#   _paq.push(['trackPageView']);
#   _paq.push(['enableLinkTracking']);
#   (function() {
#     var u='//webanalytics01.madrid.es/';
#     _paq.push(['setTrackerUrl', u+'piwik.php']);
#     _paq.push(['setSiteId', '6']);
#     var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
#     g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
#   })();
# </script>
# <!-- End Piwik Code -->"
# piwik_tracking_code_body = "<!-- Piwik -->
# <noscript><p><img src='//webanalytics01.madrid.es/piwik.php?idsite=6' style='border:0;' alt=' /></p></noscript>
# <!-- End Piwik Code -->"
# Setting[:per_page_code_head] = piwik_tracking_code_head
# Setting[:per_page_code_body] = piwik_tracking_code_body
Setting.create(key: 'analytics_url', value: "")

puts " ✅"
print "Creating Geozones"

geozones = [
  ["Fuencarral - El Pardo", "3,86,27,60,134,54,220,88,295,3,348,85,312,108,230,94,270,198,248,239,200,259,57,235,34,164"],
  ["Moncloa - Aravaca", "54,234,200,261,185,329,115,355,125,290,105,288,90,261,50,246"],
  ["Tetuán", "199,258,228,253,224,292,199,290,196,292"],
  ["Chamberí", "190,292,222,294,224,324,193,317"],
  ["Centro", "190,317,184,342,214,352,218,325"],
  ["Latina", "179,335,113,357,48,355,68,406,114,416,147,381,181,350"],
  ["Carabanchel", "178,353,198,370,176,412,116,416,176,354"],
  ["Arganzuela", "184,342,218,351,238,373,214,390,183,348"],
  ["Usera", "178,412,201,371,222,420"],
  ["Villaverde", "177,415,225,424,245,470,183,478,168,451"],
  ["Chamartín", "231,247,224,303,237,309,257,300,246,241"],
  ["Salamanca", "223,306,235,310,256,301,258,335,219,332"],
  ["Retiro", "218,334,259,338,240,369,216,350"],
  ["Puente de Vallecas", "214,390,250,356,265,362,271,372,295,384,291,397,256,406,243,420,223,422"],
  ["Villa de Vallecas", "227,423,258,407,292,397,295,387,322,398,323,413,374,440,334,494,317,502,261,468,246,471"],
  ["Hortaleza", "271,197,297,205,320,203,338,229,305,255,301,272,326,295,277,296,258,265,262,245,249,238"],
  ["Barajas", "334,217,391,207,387,222,420,274,410,305,327,295,312,283,304,258,339,232"],
  ["Ciudad Lineal", "246,240,258,243,258,267,285,307,301,347,258,338,255,271"],
  ["Moratalaz", "259,338,302,346,290,380,251,355"],
  ["San Blas-Canillejas", "282,295,404,306,372,320,351,340,335,359,303,346"],
  ["Vicálvaro", "291,381,304,347,335,362,351,342,358,355,392,358,404,342,423,360,417,392,393,387,375,438,325,413,323,393"]
]
geozones.each_with_index do |geozone, i|
  Geozone.create(name: geozone[0], html_map_coordinates: geozone[1], external_code: i.ord, census_code: i.ord)
end

Geozone.create(name: "city")
Geozone.create(name: "Existent District", census_code: "01")

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
    date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
    public_activity:        (rand(1..100) > 30)
  )
end

admin = create_user('admin@madrid.es', 'admin')
admin.create_administrator
admin.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "1111111111")
admin.create_poll_officer

moderator = create_user('mod@madrid.es', 'mod')
moderator.create_moderator

valuator = create_user('valuator@madrid.es', 'valuator')
valuator.create_valuator
valuator.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "2111111111")

manager = create_user('manager@madrid.es', 'manager')
manager.create_manager

poll_officer = create_user('poll_officer@madrid.es', 'Paul O. Fisher')
poll_officer.create_poll_officer
poll_officer.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "2211111111")

poll_officer2 = create_user('poll_officer2@consul.dev', 'Pauline M. Espinosa')
poll_officer2.create_poll_officer
poll_officer2.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3311111111")


create_user('unverified@consul.dev', 'unverified')

level_2 = create_user('leveltwo@consul.dev', 'level 2')
level_2.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: "2222222222", document_type: "1")

verified = create_user('verified@madrid.es', 'verified')
verified.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

(1..10).each do |i|
  org_name = Faker::Company.name
  org_user = create_user("org#{i}@madrid.es", org_name)
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
  official = create_user("official#{i}@madrid.es")
  official.update(official_level: i, official_position: "Official position #{i}")
end

(1..40).each do |i|
  user = create_user("user#{i}@madrid.es")
  level = [1, 2, 3].sample
  if level >= 2
    user.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: Faker::Number.number(10), document_type: "1", geozone: Geozone.reorder("RANDOM()").first)
  end
  if level == 3
    user.update(verified_at: Time.current, document_number: Faker::Number.number(10))
  end
end

org_user_ids = User.organizations.pluck(:id)
not_org_users = User.where(['users.id NOT IN(?)', org_user_ids])

puts " ✅"
print "Creating Tags Categories"

ActsAsTaggableOn::Tag.category.create!(name:  "Asociaciones")
ActsAsTaggableOn::Tag.category.create!(name:  "Cultura")
ActsAsTaggableOn::Tag.category.create!(name:  "Deportes")
ActsAsTaggableOn::Tag.category.create!(name:  "Derechos Sociales")
ActsAsTaggableOn::Tag.category.create!(name:  "Economía")
ActsAsTaggableOn::Tag.category.create!(name:  "Empleo")
ActsAsTaggableOn::Tag.category.create!(name:  "Equidad")
ActsAsTaggableOn::Tag.category.create!(name:  "Sostenibilidad")
ActsAsTaggableOn::Tag.category.create!(name:  "Participación")
ActsAsTaggableOn::Tag.category.create!(name:  "Movilidad")
ActsAsTaggableOn::Tag.category.create!(name:  "Medios")
ActsAsTaggableOn::Tag.category.create!(name:  "Salud")
ActsAsTaggableOn::Tag.category.create!(name:  "Transparencia")
ActsAsTaggableOn::Tag.category.create!(name:  "Seguridad y Emergencias")
ActsAsTaggableOn::Tag.category.create!(name:  "Medio Ambiente")

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
  voter = not_org_users.level_two_or_three_verified.reorder("RANDOM()").first
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
  author = User.reorder("RANDOM()").reject {|a| a.organization? }.first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  forum = ["true", "false"].sample
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
                                               forum: forum,
                                               price: rand(1000000),
                                               terms_of_service: "1")
end

puts " ✅"
print "Creating ballotable spending proposals for districts"
(1..60).each do |_i|
  geozone = Geozone.reorder("RANDOM()").first
  author = User.reorder("RANDOM()").reject {|a| a.organization? }.first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  forum = ["true", "false"].sample
  feasible_explanation = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  valuation_finished = true
  feasible = true
  spending_proposal = SpendingProposal.create!(author: author,
                                               title: Faker::Lorem.sentence(3).truncate(60),
                                               external_url: Faker::Internet.url,
                                               description: description,
                                               created_at: rand((Time.now - 1.week)..Time.now),
                                               geozone: geozone,
                                               feasible: feasible,
                                               feasible_explanation: feasible_explanation,
                                               valuation_finished: valuation_finished,
                                               tag_list: tags.sample(3).join(','),
                                               forum: forum,
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

  (1..([1, 2, 3].sample)).each do |i|
    group = budget.groups.create!(name: "#{Faker::StarWars.planet} #{i}")

    geozones = Geozone.reorder("RANDOM()").limit([2, 5, 6, 7].sample)
    geozones.each do |geozone|
      group.headings << group.headings.create!(name: "#{geozone.name} #{i}",
                                               price: rand(1..100) * 100000,
                                               population: rand(1..50) * 10000)
    end
  end
end

puts " ✅"
print "Creating City Heading"
Budget.first.groups.first.headings.create(name: "Toda la ciudad", price: 100_000_000)

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
print "Voting Investments"
100.times do
  voter = not_org_users.level_two_or_three_verified.reorder("RANDOM()").first
  investment = Budget::Investment.reorder("RANDOM()").first
  investment.vote_by(voter: voter, vote: true)
end

puts " ✅"
print "Balloting Investments"
100.times do
  budget = Budget.reorder("RANDOM()").first
  ballot = Budget::Ballot.create(user: User.reorder("RANDOM()").first, budget: budget)
  ballot.add_investment(budget.investments.reorder("RANDOM()").first)
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
print "Marking investments as visible to valuators"

(1..50).to_a.sample.times do
  Budget::Investment.reorder("RANDOM()").first.update(visible_to_valuators: true)
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
print "Creating district Forums"
forums = ["Fuencarral - El Pardo", "Moncloa - Aravaca", "Tetuán", "Chamberí", "Centro", "Latina", "Carabanchel", "Arganzuela", "Usera", "Villaverde", "Chamartín", "Salamanca", "Retiro", "Puente de Vallecas", "Villa de Vallecas", "Hortaleza", "Barajas", "Ciudad Lineal", "Moratalaz", "San Blas - Canillejas", "Vicálvaro"]
forums.each_with_index do |forum, i|
  user = create_user("user_for_forum#{i + 1}@example.es")
  Forum.create(name: forum, user: user)
end

puts " ✅"
print "Open plenary debate"
open_plenary = Debate.create!(author: User.reorder("RANDOM()").first,
                              title: "Pregunta en el Pleno Abierto",
                              created_at: Date.parse("20-04-2016"),
                              description: "<p>Pleno Abierto preguntas</p>",
                              terms_of_service: "1",
                              tag_list: 'plenoabierto',
                              comment_kind: 'question')

puts " ✅"
print "Open plenary questions"
(1..30).each do |_i|
  author = User.reorder("RANDOM()").first
  cached_votes_up = rand(1000)
  cached_votes_down = rand(1000)
  cached_votes_total =  cached_votes_up + cached_votes_down
  Comment.create!(user: author,
                  created_at: rand(open_plenary.created_at..Time.now),
                  commentable: open_plenary,
                  body: Faker::Lorem.sentence,
                  cached_votes_up: cached_votes_up,
                  cached_votes_down: cached_votes_down,
                  cached_votes_total: cached_votes_total)
end

puts " ✅"
print "Open plenary proposal"
(1..30).each do |_i|
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: User.reorder("RANDOM()").first,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3),
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              description: description,
                              created_at: Date.parse("20-04-2016"),
                              terms_of_service: "1",
                              tag_list: 'plenoabierto',
                              cached_votes_up: rand(1000))
end

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
                          post_ended_at:   rand((Time.current - 1.day)..(Time.current + 1.week)),
                          created_at: rand((Time.current - 1.week)..Time.current))
end

puts " ✅"
print "Creating Probe and ProbeOptions for Town Planning project"
town_planning = Probe.create(codename: "town_planning")
town_planning_options = [
  ["Balle Malle Hupe und Artur", "003"],
  ["Delta", "022"],
  ["Mas Madrid", "025"],
  ["MADBENCH", "033"],
  ["Yo tenía tres sillas en mi casa...", "036"],
  ["Sedere", "040"],
  ["TAKETE", "048"],
  ["Mucho gusto Madrid", "054"],
  ["SIENTAMADRID!", "084"],
  ["ARCO", "130"],
  ["a_park_ando", "149"],
  ["Benditas costumbres", "174"]
]

town_planning_options.each do |name, code|
  ProbeOption.create(probe_id: town_planning.id, name: name, code: code)
end

puts " ✅"
print "Creating Probe and ProbeOptions for Plaza de España project"
plaza = Probe.create(codename: "plaza")
plaza_options = [
  ["MÁS O MENOS", "01"],
  ["PARKIN", "02"],
  ["Mi rincón favorito de Madrid", "03"],
  ["Espacio España", "04"],
  ["La pluma es la lengua del alma", "05"],
  ["CONECTOR URBANO PLAZA ESPAÑA", "06"],
  ["117....142", "07"],
  ["Baile a orillas del Manzanares", "08"],
  ["Sentiré su frescor en mis plantas", "09"],
  ["UN PASEO POR LA CORNISA", "10"],
  ["QUIERO ACORDARME", "11"],
  ["MADRID AIRE", "12"],
  ["Descubriendo Plaza de España", "13"],
  ["DirdamMadrid", "14"],
  ["Alla donde se cruzan los caminos", "15"],
  ["NADA CORRE PEDALEA", "16"],
  ["El sueño de Cervantes", "19"],
  ["ESplaza", "20"],
  ["En un lugar de Madrid", "21"],
  ["CodigoAbierto", "22"],
  ["CampoCampo", "23"],
  ["El diablo cojuelo", "26"],
  ["Metamorfosis del girasol", "27"],
  ["De este a oeste", "28"],
  ["Corredor ecologico", "29"],
  ["Welcome mother Nature", "30"],
  ["PLAZA DE ESPAÑA 2017", "31"],
  ["Ñ-AGORA", "32"],
  ["OASIS24H", "33"],
  ["Madrid wild", "34"],
  ["PlazaSdeespaña", "36"],
  ["Dentro", "37"],
  ["CON MESURA", "38"],
  ["EN BUSCA DE DULCINEA", "39"],
  ["Luces de Bohemia - Madrid Cornisa", "40"],
  ["De una plaza concéntrica a un caleidoscopio de oportunidades", "41"],
  ["Cambio de Onda", "42"],
  ["La respuesta está en el 58", "44"],
  ["En un lugar de la cornisa", "45"],
  ["Continuidad de los parques", "46"],
  ["Vamos de ronda", "47"],
  ["MADRID EM-PLAZA", "48"],
  ["230306", "49"],
  ["Redibujando la plaza", "50"],
  ["TOPOFILIA", "51"],
  ["Imprescindible, necesario, deseable", "53"],
  ["3 plazas, 2 paseos, 1 gran parque", "54"],
  ["Oz", "55"],
  ["ENCUENTRO", "56"],
  ["Generando fluorescencia con molinos ", "58"],
  ["UN REFLEJO DE LA ESPAÑA RURAL", "59"],
  ["SuperSuperficie TermosSocial", "60"],
  ["DESCUBRE MADRID", "61"],
  ["VERDECOMÚN", "62"],
  ["Ecotono urbano", "63"],
  ["LA PIEL QUE HABITO", "64"],
  ["Entreplazas.Plaza España", "66"],
  ["Abracadabra", "67"],
  ["Pradera urbana", "68"],
  ["Archipielago", "69"],
  ["Flow", "70"],
  ["EN UN LUGAR DE MADRID", "71"],
  ["1968 diluir los límites, evitar las discontinuidades y más verde", "72"],
  ["MejorANDO x Pza España", "73"],
  ["RE-VERDE CON CAUSA", "74"],
  ["ECO2Madrid", "75"],
  ["THE LONG LINE", "76"],
  ["El ojo de Horus", "77"],
  ["ME VA MADRID", "78"],
  ["THE FOOL ON THE HILL", "79"]
]

plaza_options.each do |option_name, option_code|
  ProbeOption.create(probe_id: plaza.id, name: option_name, code: option_code)
end

puts " ✅"
print "Commenting probe options"

(1..100).each do |_i|
  author = User.reorder("RANDOM()").first
  probe_option = ProbeOption.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(probe_option.probe.created_at..Time.now),
                  commentable: probe_option,
                  body: Faker::Lorem.sentence)
end

puts " ✅"
print "Commenting Comments"

(1..300).each do |_i|
  author = User.reorder("RANDOM()").first
  parent = Comment.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(parent.created_at..Time.now),
                  commentable_id: parent.commentable_id,
                  commentable_type: parent.commentable_type,
                  body: Faker::Lorem.sentence,
                  parent: parent)
end

puts " ✅"
print "Creating Proposals for Human Right Proceeding"

subproceedings = ["Derecho a una vida sin violencia machista",
                  "Derecho a contar con una policía municipal democrática y eficaz",
                  "Derecho a la salud, incluida la salud sexual y reproductiva",
                  "Derecho a la vivienda",
                  "Derecho al trabajo digno",
                  "Derecho a la educación",
                  "Derecho a la cultura",
                  "Derecho al cuidado, incluyendo los derechos de las personas cuidadoras",
                  "Derecho de las mujeres a la no discriminación",
                  "Derecho de las personas gays, lesbianas, transexuales, bisexuales e intersexuales a la no discriminación",
                  "Derecho a no sufrir racismo y derechos de las personas migrantes y refugiadas",
                  "Derechos de la infancia",
                  "Derechos de las personas con diversidad funcional",
                  "Derecho a la alimentación y al agua de calidad",
                  "Derecho a la movilidad y el buen transporte en la ciudad",
                  "Derecho al desarrollo urbano sostenible",
                  "Otros derechos"]

tags = Faker::Lorem.words(25)
(1..30).each do |_i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3) + "?",
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.now - 1.week)..Time.now),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1",
                              proceeding: "Derechos Humanos",
                              sub_proceeding: subproceedings.sample)
end

print "Creating proposal notifications"

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
poll_active = Poll.create(name: "Active Poll",
                   slug: "active-poll",
                   starts_at: 1.month.ago,
                   ends_at:   1.month.from_now,
                   geozone_restricted: false)

poll_active_geolocalized = Poll.create(name: "Active Poll Restricted",
                   slug: "active-poll-restricted",
                   starts_at: 1.month.ago,
                   ends_at:   1.month.from_now,
                   geozone_restricted: true,
                   geozones: Geozone.reorder("RANDOM()").limit(3))

puts " ✅"
print "Upcoming Poll"
poll = Poll.create(name: "Upcoming Poll",
                   slug: "upcoming-poll",
                   starts_at: 1.month.from_now,
                   ends_at:   2.months.from_now)

puts " ✅"
print "Recounting Poll"
poll = Poll.create(name: "Recounting Poll",
                   # slug: "recounting-poll",
                   starts_at: 1.months.ago,
                   ends_at:   5.days.ago)

puts " ✅"
print "Expired Poll"
poll_expired = Poll.create(name: "Expired Poll",
                   slug: "expired-poll",
                   starts_at: 2.months.ago,
                   ends_at:   1.month.ago)

puts " ✅"
print "Expired Poll with Stats & Results"
poll = Poll.create(name: "Expired Poll with Stats & Results",
                   # slug: "expired-poll-with-stats-and-results",
                   starts_at: 2.months.ago,
                   ends_at:   1.month.ago,
                   results_enabled: true,
                   stats_enabled: true)

puts " ✅"
print "Creating Poll Questions"

25.times do
  poll = Poll.reorder("RANDOM()").first
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  open_at = rand(2.months.ago..2.months.from_now)
  question = Poll::Question.create!(author: author,
                                    title: Faker::Lorem.sentence(3).truncate(60),
                                    poll: poll)
  Faker::Lorem.words((2..4).to_a.sample).each do |answer|
    Poll::Question::Answer.create!(question: question, title: answer.capitalize, description: Faker::ChuckNorris.fact)
  end
end

puts " ✅"
print "Creating Poll Booths"
20.times.each_with_index do |i|
  Poll::Booth.create(name: "Booth #{i}", location: "Street #{i}", polls: [Poll.all.sample])
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
print "Creating Poll Shifts for Poll Officers"

Poll::BoothAssignment.all.each do |booth_assignment|
  Poll::Shift.create(booth_id: booth_assignment.booth_id,
                     officer_id: poll_officer.poll_officer.id,
                     date: Date.current,
                     officer_name: poll_officer.poll_officer.name,
                     officer_email: poll_officer.poll_officer.email,
                     task: 0)
  Poll::Shift.create(booth_id: booth_assignment.booth_id,
                     officer_id: poll_officer.poll_officer.id,
                     date: Date.current,
                     officer_name: poll_officer.poll_officer.name,
                     officer_email: poll_officer.poll_officer.email,
                     task: 1)
end

puts " ✅"
print "Creating Poll Questions from Proposals"

3.times do
  proposal = Proposal.reorder("RANDOM()").first
  poll = Poll.current.first
  question = Poll::Question.create(poll: poll)
  Faker::Lorem.words((2..4).to_a.sample).each do |answer|
    Poll::Question::Answer.create!(question: question, title: answer.capitalize, description: Faker::ChuckNorris.fact)
  end
  question.copy_attributes_from_proposal(proposal)
  question.save!
end

puts " ✅"
print "Creating Successful Proposals"

10.times do
  proposal = Proposal.reorder("RANDOM()").first
  poll = Poll.current.first
  question = Poll::Question.create(poll: poll)
  Faker::Lorem.words((2..4).to_a.sample).each do |answer|
    Poll::Question::Answer.create!(question: question, title: answer.capitalize, description: Faker::ChuckNorris.fact)
  end
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

puts " ✅"
print "For Active Poll"

10.times do
  user = User.level_two_verified.sample
  Poll::Voter.create(poll_id: poll_active.id, user_id: user.id, document_number: user.document_number, origin: 'web')
  user = User.level_two_verified.sample
  Poll::Voter.create(poll_id: poll_active.id, user_id: user.id, document_number: user.document_number, origin: 'booth')
end

puts " ✅"
print "For Active Geolocalized Poll"

10.times do
  user = User.level_two_verified.sample
  Poll::Voter.create(poll_id: poll_active_geolocalized.id, user_id: user.id, document_number: user.document_number, origin: 'web')
  user = User.level_two_verified.sample
  Poll::Voter.create(poll_id: poll_active_geolocalized.id, user_id: user.id, document_number: user.document_number, origin: 'booth')
end

puts " ✅"
print "For Expired Poll"

10.times do
  user = User.level_two_verified.sample
  Poll::Voter.create(poll_id: poll_expired.id, user_id: user.id, document_number: user.document_number, origin: 'web')
  user = User.level_two_verified.sample
  Poll::Voter.create(poll_id: poll_expired.id, user_id: user.id, document_number: user.document_number, origin: 'web')
end

puts " ✅"
print "Creating Poll Answers"

Poll::Voter.all.each do |voter|
  voter.poll.questions.each do |question|
    answer = question.question_answers.sample
    unless answer.nil?
      Poll::Answer.create(question_id: question.id, author_id: voter.user_id, answer: answer.title)
    end
  end
end

puts " ✅"
print "Creating Poll Recounts"

Poll.all.each do |poll|
  poll.booth_assignments.each do |booth_assignment|
    officer_assignment = poll.officer_assignments.first
    author = Poll::Officer.first.user

    Poll::Recount.create!(officer_assignment: officer_assignment,
                          booth_assignment: booth_assignment,
                          author: author,
                          date: poll.ends_at,
                          white_amount: rand(0..10),
                          null_amount: rand(0..10),
                          total_amount: rand(100..9999),
                          origin: "booth")
  end
end

puts " ✅"
print "Creating Poll Results"

Poll.all.each do |poll|
  poll.booth_assignments.each do |booth_assignment|
    officer_assignment = poll.officer_assignments.first
    author = Poll::Officer.first.user

    poll.questions.each do |question|
      question.question_answers.each do |answer|
        Poll::PartialResult.create!(officer_assignment: officer_assignment,
                                    booth_assignment: booth_assignment,
                                    date: Date.current,
                                    question: question,
                                    answer: answer.title,
                                    author: author,
                                    amount: rand(999),
                                    origin: "booth")
      end
    end
  end

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
                                           result_publication_enabled: true,
                                           published: true)
end

::Legislation::Process.all.each do |process|
  (1..3).each do |i|
    version = process.draft_versions.create!(title: "Version #{i}",
                                             body: Faker::Lorem.paragraphs.join("\n\n"))
  end
end

puts " ✅"
puts "All dev seeds created successfuly 👍"
