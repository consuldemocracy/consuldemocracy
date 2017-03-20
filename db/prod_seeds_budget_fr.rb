require 'database_cleaner'
require "csv"

DatabaseCleaner.clean_with :truncation

puts "Creating Settings"
Setting.create(key: 'official_level_1_name', value: 'COPAS')
Setting.create(key: 'official_level_2_name', value: 'Employé RIVP')
Setting.create(key: 'official_level_3_name', value: 'Responsable RIVP')
Setting.create(key: 'official_level_4_name', value: 'Conseiller municipal')
Setting.create(key: 'official_level_5_name', value: 'Le Maire')

Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')
Setting.create(key: 'max_votes_for_debate_edit', value: '1000')
Setting.create(key: 'max_votes_for_proposal_edit', value: '1000')
Setting.create(key: 'proposal_code_prefix', value: 'RIVP')
Setting.create(key: 'votes_for_proposal_success', value: '3')
Setting.create(key: 'months_to_archive_proposals', value: '12')
Setting.create(key: 'comments_body_max_length', value: '1000')

Setting.create(key: 'twitter_handle', value: '@consul_dev')
Setting.create(key: 'twitter_hashtag', value: '#consul_dev')
Setting.create(key: 'facebook_handle', value: 'consul')
Setting.create(key: 'youtube_handle', value: 'consul')
Setting.create(key: 'blog_url', value: 'https://extranet-rivp.fr/')
Setting.create(key: 'url', value: 'http://localhost:3000')
Setting.create(key: 'org_name', value: 'Budget participatif de la RIVP')
Setting.create(key: 'place_name', value: 'RIVP')
# Setting.create(key: 'feature.debates', value: "true")
Setting.create(key: 'feature.spending_proposals', value: nil)
Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: nil)
Setting.create(key: 'feature.budgets', value: "true")
# Setting.create(key: 'feature.twitter_login', value: "true")
# Setting.create(key: 'feature.facebook_login', value: "true")
# Setting.create(key: 'feature.google_login', value: "true")
Setting.create(key: 'feature.signature_sheets', value: "true")
Setting.create(key: 'per_page_code', value: "")
Setting.create(key: 'comments_body_max_length', value: '1000')
Setting.create(key: 'mailer_from_name', value: 'Budget Participatif RIVP')
Setting.create(key: 'mailer_from_address', value: 'contact@copas.coop')
Setting.create(key: 'meta_description', value: 'Budget participatif de la RIVP')
Setting.create(key: 'meta_keywords', value: 'Budget participatif, RIVP')
Setting.create(key: 'verification_offices_url', value: 'http://copas.coop/')
Setting.create(key: 'min_age_to_participate', value: '16')

puts "Creating Geozones"
# ['La Grange aux Belles', 'Bd Macdonald', "Elie Faure / Cdt l'Herminier", "Les Cardeurs - Mouraud", "Bisson Ramponneau", "La Chapelle Evangile", "Scotto Reverdy", "Cité Beauharnais", "Porte de Vanves"].each { |i| Geozone.create(name: "#{i}", external_code: i.ord, census_code: i.ord) }
['La Grange aux Belles, 10ème',
  'La Chapelle Evangile, 18ème',
  'Porte de Vanves, 14ème',
  'Les Cardeurs-Mouraud, 20ème',
  'Bisson Ramponneau-Piat, 20ème' ,
  'Bd Macdonald, 19ème',
  'Elie Faure-Commandant l’Herminier, 20ème',
  'Jean Bouton-place Henri Frenay, 12ème',
  'Zac Vaugirard, 15ème',
  'Nationale, 13ème'].each { |i| Geozone.create(name: "#{i}", external_code: i.ord, census_code: i.ord) }


puts "Creating Users"

def create_user(email, username = Faker::Name.name)
  pwd = '12345678'
  puts "    #{username}"
  User.create!(username: username, email: email, password: pwd, password_confirmation: pwd, confirmed_at: Time.current, terms_of_service: "1")
end

admin = create_user('admin@consul.dev', 'admin')
admin.create_administrator

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

# création des utilisateurs francçais

valentin = create_user('valentin@consul.dev', 'valentin')
valentin.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

alain = create_user('alain@consul.dev', 'alain')
alain.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

olivier = create_user('olivier@consul.dev', 'olivier')
olivier.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

virgile = create_user('virgile@consul.dev', 'virgile')
virgile.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

noe = create_user('noe@consul.dev', 'noe')
noe.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

hugo = create_user('hugo@consul.dev', 'hugo')
hugo.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1", verified_at: Time.current, document_number: "3333333333")

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

puts "Verified all users"

users = User.all
users.each do |user|
  user.update(verified_at: Time.current)
end

puts "Creating Tags Categories"

tags = ['Cadre de vie', 'Solidarité', 'Lien social', 'Micro aménagements']

# tags = ['Solidarité et cohésion sociale', 'Propreté', 'Environnement', 'Cadre de vie', 'Economie', 'Education jeunesse', 'Sport', 'Santé', 'Culture et Patrimoine'] # tag de la mairie de Paris
tags.each do |tag|
  ActsAsTaggableOn::Tag.create!(name:  tag, featured: true, kind: "category")
end

puts "Creating Budgets"

budget = Budget.create!(
      name: "Budget participatif 2017",
      currency_symbol: "€",
      phase: "accepting",
      description_accepting: "description_accepting ici",
      description_reviewing: "description_reviewing ici",
      description_selecting: "description_selecting ici",
      description_valuating: "description_valuating ici",
      description_balloting: "description_balloting ici",
      description_reviewing_ballots: "description_reviewing_ballots ici",
      description_finished: "description_finished ici")

puts budget.name

puts "Creating Groups"
group = budget.groups.create!(name: "Choisissez votre résidence")
group.headings << group.headings.create!(name: 'La Granges aux Belles, 10ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'La Chapelle Evangile, 18ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Porte de Vanves, 14ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Les Cardeurs-Mouraud, 20ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Bisson Ramponneau-Piat, 20ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Bd Macdonald, 19ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Elie Faure-Commandant l’Herminier, 20ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Jean Bouton-place Henri Frenay, 12ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Zac Vaugirard, 15ème',
                                        # geozone: geozone,
                                        price: 20000)
group.headings << group.headings.create!(name: 'Nationale, 13ème',
                                        # geozone: geozone,
                                        price: 20000)



with_investments = "yes"
if with_investments = "yes"
  print "Creating Investments"
  tags = ActsAsTaggableOn::Tag.where(kind: 'category')
  file = File.expand_path('../prod_seeds_fr.csv', __FILE__)
  CSV.foreach(file, :headers => true) do |row|
    heading = Budget::Heading.reorder("RANDOM()").first
    investment = Budget::Investment.create!(
      author: User.reorder("RANDOM()").first,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: row[0],
      external_url: Faker::Internet.url,
      description: row[3],
      created_at: rand((Time.now - 1.week) .. Time.now),
      feasibility: %w{undecided unfeasible feasible feasible feasible feasible}.sample,
      unfeasibility_explanation: Faker::Lorem.paragraph,
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(','),
      price: rand(1 .. 100) * 1000,
      terms_of_service: "1")
    puts "    #{investment.title}"
  end
end
