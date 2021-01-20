module SDG::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :sdg_relations, as: :relatable, dependent: :destroy, class_name: "SDG::Relation"

    %w[SDG::Goal SDG::Target SDG::LocalTarget].each do |sdg_type|
      has_many sdg_type.constantize.table_name.to_sym,
               through: :sdg_relations,
               source: :related_sdg,
               source_type: sdg_type
    end

    has_one :sdg_review, as: :relatable, dependent: :destroy, class_name: "SDG::Review"
  end

  class_methods do
    def by_goal(code)
      by_sdg_related(SDG::Goal, code)
    end

    def by_target(code)
      if SDG::Target.find_by(code: code)
        by_sdg_related(SDG::Target, code)
      else
        by_sdg_related(SDG::LocalTarget, code)
      end
    end

    def by_sdg_related(sdg_class, code)
      return all if code.blank?

      joins(sdg_class.table_name.to_sym).merge(sdg_class.where(code: code))
    end

    def sdg_reviewed
      joins(:sdg_review)
    end

    def pending_sdg_review
      left_joins(:sdg_review).merge(SDG::Review.where(id: nil))
    end
  end

  def related_sdgs
    sdg_relations.map(&:related_sdg)
  end

  def sdg_goal_list
    sdg_goals.order(:code).map(&:code).join(", ")
  end

  def sdg_target_list
    sdg_targets.sort.map(&:code).join(", ")
  end

  def sdg_related_list
    sdg_goals.order(:code).map do |goal|
      [goal, sdg_targets.where(goal: goal).sort]
    end.flatten.map(&:code).join(", ")
  end

  def sdg_related_list=(codes)
    target_codes, goal_codes = codes.tr(" ", "").split(",").partition { |code| code.include?(".") }
    targets = target_codes.map { |code| SDG::Target[code] }
    goals = goal_codes.map { |code| SDG::Goal[code] }

    transaction do
      self.sdg_targets = targets
      self.sdg_goals = (targets.map(&:goal) + goals).uniq
    end
  end
end
