module SDG::Related
  extend ActiveSupport::Concern

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
end
