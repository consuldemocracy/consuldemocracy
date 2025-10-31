class Poll::WebVote
  include ActiveModel::Validations

  attr_reader :poll, :user
  delegate :t, to: "ApplicationController.helpers"

  validate :max_answers

  def initialize(poll, user)
    @poll = poll
    @user = user
  end

  def questions
    poll.questions.for_render.sort_for_list
  end

  def answers
    @answers ||= questions.to_h do |question|
      [question.id, question.answers.where(author: user)]
    end
  end

  def update(params)
    all_valid = true

    user.with_lock do
      self.answers = given_answers(params)

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

    def given_answers(params)
      questions.to_h do |question|
        [question.id, answers_for_question(question, params[question.id.to_s])]
      end
    end

    def answers_for_question(question, question_params)
      return [] unless question_params

      if question.open?
        answer_text = question_params[:answer].to_s.strip
        if answer_text.present?
          [question.find_or_initialize_user_answer(user, answer_text: answer_text)]
        else
          []
        end
      else
        Array(question_params[:option_id]).map do |option_id|
          question.find_or_initialize_user_answer(user, option_id: option_id)
        end
      end
    end

    def max_answers
      questions.each do |question|
        if answers[question.id].count > question.max_votes
          errors.add(
            :"question_#{question.id}",
            t("polls.form.maximum_exceeded", maximum: question.max_votes, given: answers[question.id].count)
          )
        end
      end
    end
end
