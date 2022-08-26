module AUE::Related
  extend ActiveSupport::Concern
  include Comparable

  RELATABLE_TYPES = %w[
    Budget::Investment
    Debate
    Legislation::Process
    Legislation::Proposal
    Poll
    Proposal
  ].freeze

  included do
    has_many :relations, as: :related_aue, dependent: :destroy

    RELATABLE_TYPES.each do |relatable_type|
      has_many relatable_type.constantize.table_name.to_sym,
               through: :relations,
               source: :relatable,
               source_type: relatable_type
    end
  end

  def relatables
    relations.map(&:relatable)
  end

  def <=>(goal_or_target)
  end

  def code_and_title
    "#{code}. #{title}"
  end
end
