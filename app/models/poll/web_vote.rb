class Poll::WebVote
  attr_reader :poll, :user

  def initialize(poll, user)
    @poll = poll
    @user = user
  end

  def questions
    poll.questions.for_render.sort_for_list
  end

  def update(params)
    all_valid = true

    user.with_lock do
      questions.each do |question|
        question.answers.where(author: user).destroy_all
        next unless params[question.id.to_s]

        option_ids = params[question.id.to_s][:option_id]

        answers = Array(option_ids).map do |option_id|
          question.find_or_initialize_user_answer(user, option_id)
        end

        if answers.map(&:valid?).all?(true)
          Poll::Voter.find_or_create_by!(user: user, poll: poll, origin: "web")
          answers.each(&:save!)
        else
          all_valid = false
          raise ActiveRecord::Rollback
        end
      end
    end

    all_valid
  end
end
