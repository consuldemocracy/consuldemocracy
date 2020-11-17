module SDG::Related
  extend ActiveSupport::Concern

  included do
    has_many :relations, as: :related_sdg, dependent: :destroy
  end
end
