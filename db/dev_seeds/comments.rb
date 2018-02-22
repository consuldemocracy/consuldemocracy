section "Commenting Investments, Debates & Proposals" do
  %w(Budget::Investment Debate Proposal).each do |commentable_class|
    100.times do
      commentable = commentable_class.constantize.all.sample
      Comment.create!(user: User.all.sample,
                      created_at: rand(commentable.created_at..Time.current),
                      commentable: commentable,
                      body: Faker::Lorem.sentence)
    end
  end
end

section "Commenting Comments" do
  200.times do
    parent = Comment.all.sample
    Comment.create!(user: User.all.sample,
                    created_at: rand(parent.created_at..Time.current),
                    commentable_id: parent.commentable_id,
                    commentable_type: parent.commentable_type,
                    body: Faker::Lorem.sentence,
                    parent: parent)
  end
end
