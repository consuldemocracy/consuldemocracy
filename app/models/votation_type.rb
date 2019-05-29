class VotationType < ApplicationRecord
  belongs_to :questionable, polymorphic: true
  has_many :votation_set_answers

  QUESTIONABLE_TYPES = %w[Poll::Question].freeze

  ENUM_TYPES_PROPS = {
    unique: { enum_type: 0, open_answer: false, prioritized: false },
    multiple: { enum_type: 1, open_answer: false, prioritized: false,
                variables: [:max_votes] },
    prioritized: { enum_type: 2, open_answer: false, prioritized: true,
                   variables: [:max_votes, :prioritization_type] },
    positive_open: { enum_type: 3, open_answer: true, prioritized: false,
                     variables: [:max_votes] },
    positive_negative_open: { enum_type: 4, open_answer: true, prioritized: false,
                              variables: [:max_votes] },
    answer_couples_open: { enum_type: 5, open_answer: true, prioritized: false,
                           variables: [:max_votes, :display_skip_question] },
    answer_couples_closed: { enum_type: 6, open_answer: false, prioritized: false,
                             variables: [:max_votes, :display_skip_question] },
    answer_set_open: { enum_type: 7, open_answer: true, prioritized: false,
                       variables: [:max_votes, :max_groups_answers] },
    answer_set_closed: { enum_type: 8, open_answer: false, prioritized: false,
                         variables: [:max_votes, :max_groups_answers] },
  }.freeze

  enum enum_type: ENUM_TYPES_PROPS.map{ |k,v| [k, v[:enum_type]] }.to_h.freeze

  enum prioritization_type: {borda: 1, dowdall: 2}.freeze

  validates :questionable, presence: true
  validates :questionable_type, inclusion: {in: QUESTIONABLE_TYPES}
  validates_presence_of :max_votes, allow_blank: false,
                        if: :max_votes_required?
  validates_presence_of :max_groups_answers, allow_blank: false,
                        if: :max_groups_answers_required?
  validates_presence_of :prioritization_type, allow_blank: false,
                        if: :prioritization_type_required?

  after_create :add_skip_question_answer, if: :display_skip_question?

  attr_accessor :display_skip_question

  def open?
    open_answer
  end

  def prioritized?
    prioritized
  end

  def answer (user, answer, options = {})
    result = nil
    votes = questionable.answers

    if votable_question?(answer)
      case enum_type
      when "unique"
        result = votes.find_or_initialize_by(author: user)

      when "multiple", "positive_open"
        if check_max_votes(user, votes)
          result = votes.find_or_initialize_by(author: user, answer: answer)
        end

      when "prioritized"
        result = votes.find_by(author: user, answer: answer)
        if result.nil?
          if check_max_votes(user, votes)
            if votes.by_author(user.id).empty?
              order = 1
            else
              order = votes.by_author(user.id).order(:order).last.order + 1
            end
            result = votes.find_or_initialize_by(author: user,
                                                 answer: answer,
                                                 order: order)
          end
        else
          !result.update(order: options[:order])
        end

      when "positive_negative_open"
        result = votes.by_author(user.id).find_by(answer: answer)
        if result.nil?
          if check_max_votes(user, votes)
            result = votes.create(author: user,
                                  answer: answer,
                                  positive: options[:positive])
          end
        else
          !result.update(positive: options[:positive])
        end

      when "answer_couples_closed", "answer_couples_open"
        if check_max_votes(user, votes)
          result = votes.create(
            answer: answer,
            author: user,
            positive: true,
            order: votes&.by_author(user.id).count + 1
          )
        end
        Poll::PairAnswer.generate_pair(questionable, user)

      when "answer_set_open", "answer_set_closed"
        if check_max_votes(user, votes) && answer_in_set?(answer, user)
          result = votes&.find_or_initialize_by(author: user, answer: answer)
        end
      end
    end


    result
  end

  def create_question_answer(answer, hidden=false)
    return if questionable.question_answers.where(title: answer).any?

    questionable.question_answers
      .create(
        title: answer,
        given_order: questionable.question_answers.maximum(:given_order).to_i + 1,
        hidden: hidden
      )
    true
  end

  def votable_question?(answer)
    questionable.question_answers.where(title: answer).present?
  end

  def self.build_by_type(questionable, params)
    attributes      = {questionable: questionable}
    enum_type       = self.enum_types.key(params[:enum_type].to_i)
    enum_type_props = enum_properties(enum_type)
    attributes.merge!(enum_type_props.except(:variables))
    enum_type_props[:variables]&.each do |property|
      attributes[property] = params[property]
    end
    attributes[:prioritization_type] = attributes[:prioritization_type]&.to_i
    new(attributes)
  end

  def self.create_by_type(questionable, params)
    votation_type = build_by_type(questionable, params)
    votation_type.save
  end

  def update_priorized_values(user)
    case prioritization_type
    when "borda"
      questionable.answers.by_author(user).order(:order).each_with_index do |answer, i|
        value = max_votes - i
        !answer.update(value: value)
      end
    when "dowdall"
      questionable.answers.by_author(user).order(:order).each_with_index do |answer, i|
        value = 60/(i + 1)
        !answer.update(value: value)
      end
    end
  end

  private

    def answer_in_set?(answer, user)
      votation_set_answers&.by_author(user)&.pluck(:answer).include?(answer)
    end

    def check_max_votes(user, votes)
      max_votes > votes&.by_author(user.id).count
    end

    def self.enum_properties(enum_type)
      ENUM_TYPES_PROPS[enum_type&.to_sym] || ENUM_TYPES_PROPS[:unique]
    end

    def self.enum_properties_variables(enum_type)
      enum_properties(enum_type)&.dig(:variables)
    end

    def max_votes_required?
      VotationType.enum_properties_variables(self.enum_type)&.include?(:max_votes)
    end

    def max_groups_answers_required?
      VotationType.enum_properties_variables(self.enum_type)&.include?(:max_groups_answers)
    end

    def prioritization_type_required?
      VotationType.enum_properties_variables(self.enum_type)&.include?(:prioritization_type)
    end

    def display_skip_question?
      VotationType.enum_properties_variables(self.enum_type)&.include?(:display_skip_question)
    end

    def add_skip_question_answer
      create_question_answer("I can't decided", true)
    end
end
