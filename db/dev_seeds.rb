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

Setting.create(key: 'blog_url', value: '/blog')
Setting.create(key: 'url', value: 'http://localhost:3000')
Setting.create(key: 'org_name', value: 'Consul')
Setting.create(key: 'place_name', value: 'City')
Setting.create(key: 'feature.debates', value: "true")
Setting.create(key: 'feature.spending_proposals', value: "true")
Setting.create(key: 'feature.twitter_login', value: "true")
Setting.create(key: 'feature.facebook_login', value: "true")
Setting.create(key: 'feature.google_login', value: "true")

Setting.create(key: 'comments_body_max_length', value: '1000')

puts "Creating Geozones"

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
  ["Chamartin", "231,247,224,303,237,309,257,300,246,241"],
  ["Salamanca", "223,306,235,310,256,301,258,335,219,332"],
  ["Retiro", "218,334,259,338,240,369,216,350"],
  ["Puente de Vallecas", "214,390,250,356,265,362,271,372,295,384,291,397,256,406,243,420,223,422"],
  ["Villa de Vallecas", "227,423,258,407,292,397,295,387,322,398,323,413,374,440,334,494,317,502,261,468,246,471"],
  ["Hortaleza", "271,197,297,205,320,203,338,229,305,255,301,272,326,295,277,296,258,265,262,245,249,238"],
  ["Barajas", "334,217,391,207,387,222,420,274,410,305,327,295,312,283,304,258,339,232"],
  ["Ciudad Lineal", "246,240,258,243,258,267,285,307,301,347,258,338,255,271"],
  ["Moratalaz", "259,338,302,346,290,380,251,355"],
  ["San Blas - Canillejas", "282,295,404,306,372,320,351,340,335,359,303,346"],
  ["Vicálvaro", "291,381,304,347,335,362,351,342,358,355,392,358,404,342,423,360,417,392,393,387,375,438,325,413,323,393"]
]
geozones.each do |name, coordinates|
  Geozone.create(name: name, html_map_coordinates: coordinates)
end

puts "Creating Users"

def create_user(email, username = Faker::Name.name)
  pwd = '12345678'
  puts "    #{username}"
  User.create!(username: username, email: email, password: pwd, password_confirmation: pwd, confirmed_at: Time.now, terms_of_service: "1")
end

admin = create_user('admin@madrid.es', 'admin')
admin.create_administrator

moderator = create_user('mod@madrid.es', 'mod')
moderator.create_moderator

valuator = create_user('valuator@madrid.es', 'valuator')
valuator.create_valuator

(1..10).each do |i|
  org_name = Faker::Company.name
  org_user = create_user("org#{i}@madrid.es", org_name)
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
  official = create_user("official#{i}@madrid.es")
  official.update(official_level: i, official_position: "Official position #{i}")
end

(1..40).each do |i|
  user = create_user("user#{i}@madrid.es")
  level = [1,2,3].sample
  if level >= 2 then
    user.update(residence_verified_at: Time.now, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: Faker::Number.number(10), document_type: "1" )
  end
  if level == 3 then
    user.update(verified_at: Time.now, document_number: Faker::Number.number(10) )
  end
end

org_user_ids = User.organizations.pluck(:id)
not_org_users = User.where(['users.id NOT IN(?)', org_user_ids])

puts "Creating Tags Categories"

ActsAsTaggableOn::Tag.create!(name:  "Asociaciones", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Cultura", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Deportes", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Derechos Sociales", featured: true, kind: "category")
ActsAsTaggableOn::Tag.create!(name:  "Distritos", featured: true, kind: "category")
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
ActsAsTaggableOn::Tag.create!(name:  "Urbanismo", featured: true, kind: "category")

puts "Creating Debates"

tags = Faker::Lorem.words(25)
(1..30).each do |i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3).truncate(60),
                          created_at: rand((Time.now - 1.week) .. Time.now),
                          description: description,
                          tag_list: tags.sample(3).join(','),
                          geozone: Geozone.reorder("RANDOM()").first,
                          terms_of_service: "1")
  puts "    #{debate.title}"
end


tags = ActsAsTaggableOn::Tag.where(kind: 'category')
(1..30).each do |i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3).truncate(60),
                          created_at: rand((Time.now - 1.week) .. Time.now),
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
                              question: Faker::Lorem.sentence(3),
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.now - 1.week) .. Time.now),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1")
  puts "    #{proposal.title}"
end


tags = ActsAsTaggableOn::Tag.where(kind: 'category')
(1..30).each do |i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3),
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.now - 1.week) .. Time.now),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1")
  puts "    #{proposal.title}"
end


puts "Commenting Debates"

(1..100).each do |i|
  author = User.reorder("RANDOM()").first
  debate = Debate.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(debate.created_at .. Time.now),
                  commentable: debate,
                  body: Faker::Lorem.sentence)
end


puts "Commenting Proposals"

(1..100).each do |i|
  author = User.reorder("RANDOM()").first
  proposal = Proposal.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(proposal.created_at .. Time.now),
                  commentable: proposal,
                  body: Faker::Lorem.sentence)
end


puts "Commenting Comments"

(1..200).each do |i|
  author = User.reorder("RANDOM()").first
  parent = Comment.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(parent.created_at .. Time.now),
                  commentable_id: parent.commentable_id,
                  commentable_type: parent.commentable_type,
                  body: Faker::Lorem.sentence,
                  parent: parent)
end


puts "Voting Debates, Proposals & Comments"

(1..100).each do |i|
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

(1..100).each do |i|
  voter  = User.level_two_or_three_verified.reorder("RANDOM()").first
  proposal = Proposal.reorder("RANDOM()").first
  proposal.vote_by(voter: voter, vote: true)
end


puts "Flagging Debates & Comments"

(1..40).each do |i|
  debate = Debate.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", debate.author_id]).reorder("RANDOM()").first
  Flag.flag(flagger, debate)
end

(1..40).each do |i|
  comment = Comment.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", comment.user_id]).reorder("RANDOM()").first
  Flag.flag(flagger, comment)
end

(1..40).each do |i|
  proposal = Proposal.reorder("RANDOM()").first
  flagger = User.where(["users.id <> ?", proposal.author_id]).reorder("RANDOM()").first
  Flag.flag(flagger, proposal)
end

puts "Creating Spending Proposals"

tags = Faker::Lorem.words(10)

(1..60).each do |i|
  geozone = Geozone.reorder("RANDOM()").first
  author = User.reorder("RANDOM()").reject {|a| a.organization? }.first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  forum = ["true", "false"].sample
  spending_proposal = SpendingProposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.now - 1.week) .. Time.now),
                              geozone: [geozone, nil].sample,
                              tag_list: tags.sample(3).join(','),
                              forum: forum,
                              terms_of_service: "1")
  puts "    #{spending_proposal.title}"
end

puts "Creating Valuation Assignments"

(1..17).to_a.sample.times do
  SpendingProposal.reorder("RANDOM()").first.valuators << valuator.valuator
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

puts "Creating district Forums"
forums = ["Leganes", "Retiro", "Vallecas", "Salamanca"]
forums.each do |forum|
  user = User.unverified.reorder("RANDOM()").reject {|u| u.organization? }.first
  Forum.create(name: forum, user: user)
end
