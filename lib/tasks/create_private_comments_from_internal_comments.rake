namespace :create_private_comments_form_internal_comments do

  desc "Create comments"
  task create: :environment do
    admin_id = Administrator.first.user_id
    Budget::Investment.where('internal_comments is not null').find_each do |investment|
      unless investment.internal_comments.blank?
        Comment.create(commentable_id: investment.id, commentable_type: "Budget::Investment",
                       body: "commentario 1", subject: investment.internal_comments,
                       user_id: admin_id, concealed: true)
        investment.internal_comments = nil
        investment.save!
      end
    end
  end

end
