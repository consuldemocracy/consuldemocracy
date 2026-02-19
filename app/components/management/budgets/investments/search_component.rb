class Management::Budgets::Investments::SearchComponent < ApplicationComponent
  attr_reader :budget, :url
  delegate :budget_heading_select_options, to: :helpers

  def initialize(budget, url:)
    @budget = budget
    @url = url
  end

  private

    def options
      {
        method: :get,
        class: "management-investments-search"
      }
    end

    def search_label_text
      t("management.budget_investments.search.label")
    end

    def attribute_name(attribute)
      Budget::Investment.human_attribute_name(attribute)
    end
end
