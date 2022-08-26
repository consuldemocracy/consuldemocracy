module AUE::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :aue_relations, as: :relatable, dependent: :destroy, class_name: "AUE::Relation"

    %w[AUE::Goal].each do |aue_type|
      has_many aue_type.constantize.table_name.to_sym,
               through: :aue_relations,
               source: :related_aue,
               source_type: aue_type
    end

  end

  class_methods do
    def by_goal(code)
      by_aue_related(:aue_goals, code)
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

  def related_aue_list
    related_aues.sort.map(&:code).join(", ")
  end

  def related_aue_list=(codes)
    goals = codes.map { |code| AUE::Goal[code] }

    transaction do
      self.aue_goals = (goals).uniq
    end
  end
end
