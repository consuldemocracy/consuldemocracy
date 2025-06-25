class Poll::WebVote
  include ActiveModel::Validations
  attr_reader :poll, :user

  validate :max_answers

  def initialize(poll, user)
    @poll = poll
    @user = user
  end

  def questions
    poll.questions.for_render.sort_for_list
  end

  def update(params)
    self.answers = answers_for(params)
    all_valid = true

    user.with_lock do
      questions.each do |question|
        question.answers.where(author: user).where.not(id: answers[question.id].map(&:id)).destroy_all

        if valid? && answers[question.id].all?(&:valid?)
          Poll::Voter.find_or_create_by!(user: user, poll: poll, origin: "web")
          answers[question.id].each(&:save!)
        else
          all_valid = false
        end
      end

      raise ActiveRecord::Rollback unless all_valid
    end

    all_valid
  end

  def to_key
  end

  def persisted?
    Poll::Voter.where(user: user, poll: poll, origin: "web").exists?
  end

  private

    attr_writer :answers

    def answers
      @answers ||= {}
    end

    def answers_for(params)
      questions.to_h do |question|
        [question.id, answers_for_question(question, params[question.id.to_s])]
      end
    end

    def answers_for_question(question, question_params)
      return [] unless question_params

      Array(question_params[:option_id]).map do |option_id|
        question.find_or_initialize_user_answer(user, option_id)
      end
    end

    def max_answers
      questions.each do |question|
        if answers[question.id].count > question.max_votes
          errors.add(:"question_#{question.id}", "TEM ERPR")
        end
      end
    end
end
