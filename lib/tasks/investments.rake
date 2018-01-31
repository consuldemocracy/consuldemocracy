namespace :investments do
  namespace :internal_comments do
    desc "Migrate internal_comments textarea to a first comment on internal thread"
    task migrate_to_thread: :environment do
      comments_author_id = Administrator.first.user.id
      Budget::Investment.where.not(internal_comments: [nil, '']).find_each do |investment|
        Comment.create(commentable: investment, user_id: comments_author_id,
                       body: investment.internal_comments, valuation: true)
      end
    end
  end
end
