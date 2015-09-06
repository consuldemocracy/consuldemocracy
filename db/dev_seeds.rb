require 'database_cleaner'

DatabaseCleaner.clean_with :truncation

puts "Creating Settings"
Setting.create(key: 'official_level_1_name', value: 'Empleados públicos')
Setting.create(key: 'official_level_2_name', value: 'Organización Municipal')
Setting.create(key: 'official_level_3_name', value: 'Directores generales')
Setting.create(key: 'official_level_4_name', value: 'Concejales')
Setting.create(key: 'official_level_5_name', value: 'Alcaldesa')
Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')

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

(1..10).each do |i|
  org_name = Faker::Company.name
  org_user = create_user("org#{i}@madrid.es", org_name)
  org = org_user.create_organization(name: org_name)

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
  create_user("user#{i}@madrid.es")
end

org_user_ids = User.organizations.pluck(:id)
not_org_users = User.where(['users.id NOT IN(?)', org_user_ids])


puts "Creating Debates"

tags = Faker::Lorem.words(25)

(1..30).each do |i|
  author = User.reorder("RANDOM()").first
  description = "<p>#{Faker::Lorem.paragraphs.join('</p></p>')}</p>"
  debate = Debate.create!(author: author,
                          title: Faker::Lorem.sentence(3),
                          created_at: rand((Time.now - 1.week) .. Time.now),
                          description: description,
                          tag_list: tags.sample(3).join(','),
                          terms_of_service: "1")
  puts "    #{debate.title}"
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


puts "Commenting Comments"

(1..100).each do |i|
  author = User.reorder("RANDOM()").first
  parent = Comment.reorder("RANDOM()").first
  Comment.create!(user: author,
                  created_at: rand(parent.created_at .. Time.now),
                  commentable_id: parent.commentable_id,
                  commentable_type: parent.commentable_type,
                  body: Faker::Lorem.sentence,
                  parent: parent)
end


puts "Voting Debates & Comments"

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


puts "Ignoring flags in Debates & comments"

Debate.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
Comment.flagged.reorder("RANDOM()").limit(30).each(&:ignore_flag)


puts "Hiding debates & comments"

Comment.with_hidden.flagged.reorder("RANDOM()").limit(30).each(&:hide)
Debate.with_hidden.flagged.reorder("RANDOM()").limit(5).each(&:hide)


puts "Confirming hiding in debates & comments"

Comment.only_hidden.flagged.reorder("RANDOM()").limit(10).each(&:confirm_hide)
Debate.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)





