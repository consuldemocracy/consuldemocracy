class VotationType < ApplicationRecord
  belongs_to :questionable, polymorphic: true

  QUESTIONABLE_TYPES = %w[Poll::Question].freeze

  ENUM_TYPES_PROPS = {
    unique: { enum_type: 0, prioritized: false },
    multiple: { enum_type: 1, prioritized: false, variables: [:max_votes] },
    prioritized: { enum_type: 2, prioritized: true, variables: [:max_votes] }
  }.freeze

  enum enum_type: ENUM_TYPES_PROPS.transform_values { |v| v[:enum_type] }.freeze

  validates :questionable, presence: true
  validates :questionable_type, inclusion: { in: QUESTIONABLE_TYPES }
  validates :max_votes, presence: true, allow_blank: false, if: :max_votes_required?

  def prioritized?
    prioritized
  end

  def answer(user, answer, options = {})
    result = nil
    votes = questionable.answers

    if votable_question?(answer)
      case enum_type
      when "unique"
        result = votes.find_or_initialize_by(author: user)
      when "multiple"
        if check_max_votes(user, votes)
          result = votes.find_or_initialize_by(author: user, answer: answer)
        end
      when "prioritized"
        result = votes.find_by(author: user, answer: answer)
        if result.present?
          result.update!(order: options[:order])
        else
          if check_max_votes(user, votes)
            if votes.by_author(user.id).empty?
              order = 1
            else
              order = votes.by_author(user.id).order(:order).last.order + 1
            end
            result = votes.find_or_initialize_by(author: user, answer: answer, order: order)
          end
        end
      end
    end

    result
  end

  def votable_question?(answer)
    questionable.question_answers.where(title: answer).present?
  end

  def self.build_by_type(questionable, params)
    attributes      = { questionable: questionable }
    enum_type       = enum_types.key(params[:enum_type].to_i)
    enum_type_props = enum_properties(enum_type)
    attributes.merge!(enum_type_props.except(:variables))
    enum_type_props[:variables]&.each do |property|
      attributes[property] = params[property]
    end
    new(attributes)
  end

  def self.create_by_type(questionable, params)
    votation_type = build_by_type(questionable, params)
    votation_type.save!
  end

  def update_priorized_values(user)
    questionable.answers.by_author(user).order(:order).each_with_index do |answer, i|
      value = max_votes - i
      answer.update!(value: value)
    end
  end

  private

    def check_max_votes(user, votes)
      votes_count = votes.by_author(user.id).count rescue 0
      max_votes > votes_count
    end

    def self.enum_properties(enum_type)
      ENUM_TYPES_PROPS[enum_type&.to_sym] || ENUM_TYPES_PROPS[:unique]
    end

    def self.enum_properties_variables(enum_type)
      enum_properties(enum_type)&.dig(:variables)
    end

    def max_votes_required?
      VotationType.enum_properties_variables(enum_type)&.include?(:max_votes)
    end
end
