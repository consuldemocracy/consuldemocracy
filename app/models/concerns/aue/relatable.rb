module AUE::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :aue_relations, as: :relatable, dependent: :destroy, class_name: "AUE::Relation"

    has_many :aue_goals,
             through: :aue_relations,
             source: :related_aue,
             source_type: "AUE::Goal"

    has_many :aue_local_goals,
             through: :aue_relations,
             source: :related_aue,
             source_type: "AUE::LocalGoal"

  end

  class_methods do
    def by_aue_goal(code)
      by_aue_related(:aue_goals, code)
    end

    def by_aue_local_goal(code)
      by_aue_related(:aue_local_goals, code)
    end

    def by_aue_related(association, code)
      return all if code.blank?

      aue_class = reflect_on_association(association).options[:source_type].constantize

      joins(association).merge(aue_class.where(code: code))
    end

  end

  def related_aues
    aue_relations.map(&:related_aue)
  end

  def aue_goal_list
    aue_goals.order(:code).map(&:code).join(", ")
  end

  def aue_local_goal_list
    aue_local_goals.order(:code).map(&:code).join(", ")
  end

  def related_aue_list
    aue_goals_and_local_goals = related_aues.map do |goal|
      goal.altcode
    end
    aue_goals_and_local_goals.join(", ")
  end

  def related_aue_list=(codes)
    local_codes, goal_codes = codes.tr(" ", "").split(",").partition { |code| code.include?('local-') }
    local_goal_codes = local_codes.map { |code| code.split("local-")[1]}

    goals = goal_codes.map { |code| AUE::Goal[code] }
    local_goals = local_goal_codes.map { |code| AUE::LocalGoal[code] }

    transaction do
      self.aue_goals = (goals).uniq
      self.aue_local_goals = (local_goals).uniq
    end
  end
end
