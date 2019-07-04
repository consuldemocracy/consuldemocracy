class Budget::Translation < Globalize::ActiveRecord::Translation
  validate :name_uniqueness_by_budget

  def name_uniqueness_by_budget
    if Budget.joins(:translations)
             .where(name: name)
             .where.not("budget_translations.budget_id": budget_id).any?
      errors.add(:name, I18n.t("errors.messages.taken"))
    end
  end
end
