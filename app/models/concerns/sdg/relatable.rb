module SDG::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :sdg_relations, as: :relatable, dependent: :destroy, class_name: "SDG::Relation"

    %w[SDG::Goal SDG::LocalTarget].each do |sdg_type|
      has_many sdg_type.constantize.table_name.to_sym,
               through: :sdg_relations,
               source: :related_sdg,
               source_type: sdg_type
    end
    has_many :sdg_global_targets,
             through: :sdg_relations,
             source: :related_sdg,
             source_type: "SDG::Target"

    has_one :sdg_review, as: :relatable, dependent: :destroy, class_name: "SDG::Review"
  end

  class_methods do
    def by_goal(code)
      by_sdg_related(:sdg_goals, code)
    end

    def by_target(code)
      if SDG::Target.find_by(code: code)
        by_sdg_related(:sdg_global_targets, code)
      else
        by_sdg_related(:sdg_local_targets, code)
      end
    end

    def by_sdg_related(association, code)
      return all if code.blank?

      sdg_class = reflect_on_association(association).options[:source_type].constantize

      joins(association).merge(sdg_class.where(code: code))
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

  def sdg_targets
    sdg_global_targets + sdg_local_targets
  end

  def sdg_targets=(targets)
    global_targets, local_targets = targets.partition { |target| target.class.name == "SDG::Target" }

    transaction do
      self.sdg_global_targets = global_targets
      self.sdg_local_targets = local_targets
    end
  end

  def sdg_goal_list
    sdg_goals.order(:code).map(&:code).join(", ")
  end

  def sdg_target_list
    sdg_targets.sort.map(&:code).join(", ")
  end

  def related_sdg_list
    related_sdgs.sort.map(&:code).join(", ")
  end

  def related_sdg_list=(codes)
    target_codes, goal_codes = codes.tr(" ", "").split(",").partition { |code| code.include?(".") }
    local_targets_codes, global_targets_codes = target_codes.partition { |code| code.split(".")[2] }
    global_targets = global_targets_codes.map { |code| SDG::Target[code] }
    local_targets = local_targets_codes.map { |code| SDG::LocalTarget[code] }
    goals = goal_codes.map { |code| SDG::Goal[code] }

    transaction do
      self.sdg_local_targets = local_targets
      self.sdg_global_targets = global_targets
      self.sdg_goals = (global_targets.map(&:goal) + local_targets.map(&:goal) + goals).uniq
    end
  end
end
