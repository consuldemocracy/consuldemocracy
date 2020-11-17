module SDG::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :sdg_relations, as: :relatable, dependent: :destroy, class_name: "SDG::Relation"
  end
end
