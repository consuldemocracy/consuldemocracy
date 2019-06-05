class Budget::Heading::Translation < Globalize::ActiveRecord::Translation
  delegate :budget, to: :globalized_model

  validate :name_uniqueness_by_budget

  def name_uniqueness_by_budget
    if budget.headings
             .joins(:translations)
             .where(name: name)
             .where.not("budget_heading_translations.budget_heading_id": budget_heading_id).any?
      errors.add(:name, I18n.t("errors.messages.taken"))
    end
  end
end
