class Budget::Group::Translation < Globalize::ActiveRecord::Translation
  delegate :budget, to: :globalized_model

  validate :name_uniqueness_by_budget

  def name_uniqueness_by_budget
    if budget.groups.joins(:translations)
                    .where(name: name)
                    .where.not("budget_group_translations.budget_group_id": budget_group_id).any?
      errors.add(:name, I18n.t("errors.messages.taken"))
    end
  end
end
