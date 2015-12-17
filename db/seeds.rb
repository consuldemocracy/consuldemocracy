# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@bcn.cat', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.now, terms_of_service: "1")
  admin.create_administrator
end

if ENV["SEED"]
  def create_user(email, username = Faker::Name.name)
    pwd = '12345678'
    puts "    #{username}"
    User.create!(username: username, email: email, password: pwd, password_confirmation: pwd, confirmed_at: Time.now, terms_of_service: "1")
  end

  puts "Creating users"
  moderator = create_user('mod@bcn.cat', 'mod')
  moderator.create_moderator

  (1..10).each do |i|
    org_name = Faker::Company.name
    org_user = create_user("org#{i}@bcn.cat", org_name)
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
    official = create_user("official#{i}@bcn.cat")
    official.update(official_level: i, official_position: "Official position #{i}")
  end

  (1..40).each do |i|
    user = create_user("user#{i}@bcn.cat")
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
end
