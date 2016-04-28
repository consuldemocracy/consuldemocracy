require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

puts "Creating Settings"
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

Setting.create(key: 'twitter_handle', value: '@consul_dev')
Setting.create(key: 'twitter_hashtag', value: '#consul_dev')
Setting.create(key: 'facebook_handle', value: 'consul')
Setting.create(key: 'youtube_handle', value: 'consul')
Setting.create(key: 'blog_url', value: '/blog')
Setting.create(key: 'url', value: 'http://localhost:3000')
Setting.create(key: 'org_name', value: 'Consul')
Setting.create(key: 'place_name', value: 'City')
Setting.create(key: 'feature.debates', value: "true")
Setting.create(key: 'feature.spending_proposals', value: "true")
Setting.create(key: 'feature.spending_proposal_features.phase1', value: "true")
Setting.create(key: 'feature.spending_proposal_features.phase2', value: nil)
Setting.create(key: 'feature.spending_proposal_features.phase3', value: nil)
Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: "true")
Setting.create(key: 'feature.spending_proposal_features.final_voting_allowed', value: "true")
Setting.create(key: 'feature.spending_proposal_features.open_results_page', value: nil)
Setting.create(key: 'feature.twitter_login', value: "true")
Setting.create(key: 'feature.facebook_login', value: "true")
Setting.create(key: 'feature.google_login', value: "true")
Setting.create(key: 'feature.probe.plaza', value: 'true')
Setting.create(key: 'per_page_code', value: "")
Setting.create(key: 'comments_body_max_length', value: '1000')
Setting.create(key: 'analytics_url', value: "")

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
  ["Chamartín", "231,247,224,303,237,309,257,300,246,241"],
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
  User.create!(username: username, email: email, password: pwd, password_confirmation: pwd, confirmed_at: Time.now, date_of_birth: (16..100).to_a.sample.years.ago, terms_of_service: "1")
end

admin = create_user('admin@consul.dev', 'admin')
admin.create_administrator

moderator = create_user('mod@consul.dev', 'mod')
moderator.create_moderator

valuator = create_user('valuator@consul.dev', 'valuator')
valuator.create_valuator

level_2 = create_user('leveltwo@consul.dev', 'level 2')
level_2.update(residence_verified_at: Time.now, confirmed_phone: Faker::PhoneNumber.phone_number, document_number: "2222222222", document_type: "1" )

verified = create_user('verified@consul.dev', 'verified')
verified.update(residence_verified_at: Time.now, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.now, document_number: "3333333333")

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
                              question: Faker::Lorem.sentence(3) + "?",
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

puts "Creating Archived Proposals"

tags = Faker::Lorem.words(25)
(1..5).each do |i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  proposal = Proposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              question: Faker::Lorem.sentence(3) + "?",
                              summary: Faker::Lorem.sentence(3),
                              responsible_name: Faker::Name.name,
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.now - 1.week) .. Time.now),
                              tag_list: tags.sample(3).join(','),
                              geozone: Geozone.reorder("RANDOM()").first,
                              terms_of_service: "1",
                              created_at: Setting["months_to_archive_proposals"].to_i.months.ago)
  puts "    #{proposal.title}"
end


tags = ActsAsTaggableOn::Tag.where(kind: 'category')
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
  feasible_explanation = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  valuation_finished = [true, false].sample
  feasible = [true, false].sample
  spending_proposal = SpendingProposal.create!(author: author,
                              title: Faker::Lorem.sentence(3).truncate(60),
                              external_url: Faker::Internet.url,
                              description: description,
                              created_at: rand((Time.now - 1.week) .. Time.now),
                              geozone: [geozone, nil].sample,
                              feasible: feasible,
                              feasible_explanation: feasible_explanation,
                              valuation_finished: valuation_finished,
                              tag_list: tags.sample(3).join(','),
                              forum: forum,
                              price: rand(1000000),
                              terms_of_service: "1")
  puts "    #{spending_proposal.title}"
end

puts "Creating Valuation Assignments"

(1..17).to_a.sample.times do
  SpendingProposal.reorder("RANDOM()").first.valuators << valuator.valuator
end

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
forums = ["Fuencarral - El Pardo", "Moncloa - Aravaca", "Tetuán", "Chamberí", "Centro", "Latina", "Carabanchel", "Arganzuela", "Usera", "Villaverde", "Chamartín", "Salamanca", "Retiro", "Puente de Vallecas", "Villa de Vallecas", "Hortaleza", "Barajas", "Ciudad Lineal", "Moratalaz", "San Blas - Canillejas", "Vicálvaro"]
forums.each_with_index do |forum, i|
  user = create_user("user_for_forum#{i+1}@example.es")
  Forum.create(name: forum, user: user)
end

puts "Open plenary debate"
open_plenary = Debate.create!(author: User.reorder("RANDOM()").first,
                        title: "Pregunta en el Pleno Abierto",
                        created_at: Date.parse("20-04-2016"),
                        description: "<p>Pleno Abierto preguntas</p>",
                        terms_of_service: "1",
                        tag_list: 'plenoabierto',
                        comment_kind: 'question')
puts "#{open_plenary.title}"

puts "Open plenary questions"
(1..30).each do |i|
  author = User.reorder("RANDOM()").first
  cached_votes_up = rand(1000)
  cached_votes_down = rand(1000)
  cached_votes_total =  cached_votes_up + cached_votes_down
  Comment.create!(user: author,
                  created_at: rand(open_plenary.created_at .. Time.now),
                  commentable: open_plenary,
                  body: Faker::Lorem.sentence,
                  cached_votes_up: cached_votes_up,
                  cached_votes_down: cached_votes_down,
                  cached_votes_total: cached_votes_total)
end

puts "Open plenary proposal"
(1..30).each do |i|
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
  puts "#{proposal.title}"
end

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
                          post_started_at: rand((Time.now - 1.week) .. (Time.now - 1.day)),
                          post_ended_at:   rand((Time.now  - 1.day) .. (Time.now + 1.week)),
                          created_at: rand((Time.now - 1.week) .. Time.now))
  puts "    #{banner.title}"
end

puts "Creating Probe and ProbeOptions for Town Planning project"
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
["Benditas costumbres", "174"]]

town_planning_options.each do |name, code|
  ProbeOption.create(probe_id: town_planning.id, name: name, code: code)
end

puts "Creating Probe and ProbeOptions for Plaza de España project"
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
["Welcome mother Nature, good bye Mr Ford", "30"],
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
["THE FOOL ON THE HILL", "79"]]

plaza_options.each do |option_name, option_code|
  ProbeOption.create(probe_id: plaza.id, name: option_name, code: option_code)
end

puts "Commenting probe options"

(1..100).each do |i|
  author = User.reorder("RANDOM()").first
  probe_option = ProbeOption.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(probe_option.probe.created_at .. Time.now),
                  commentable: probe_option,
                  body: Faker::Lorem.sentence)
end

puts "Commenting Comments"

(1..300).each do |i|
  author = User.reorder("RANDOM()").first
  parent = Comment.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(parent.created_at .. Time.now),
                  commentable_id: parent.commentable_id,
                  commentable_type: parent.commentable_type,
                  body: Faker::Lorem.sentence,
                  parent: parent)
end
