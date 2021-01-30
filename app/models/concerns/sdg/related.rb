module SDG::Related
  extend ActiveSupport::Concern
  include Comparable

  RELATABLE_TYPES = %w[
    Budget::Investment
    Debate
    Legislation::Process
    Poll
    Proposal
  ].freeze

  included do
    has_many :relations, as: :related_sdg, dependent: :destroy

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
    if goal_or_target.class.ancestors.include?(SDG::Related)
      subcodes <=> goal_or_target.subcodes
    end
  end

  def subcodes
    code.to_s.split(".").map do |subcode|
      if subcode.to_i.positive?
        subcode.to_i
      else
        subcode.to_i(36) * 1000
      end
    end
  end
end
