class Budget::Investment::Exporter
  require "csv"

  def initialize(investments)
    @investments = investments
  end

  def to_csv

    string = CSV.generate(col_sep: ';', encoding: 'UTF-8', headers: true) do |csv|
      csv << headers
      @investments.each { |investment| csv << csv_values(investment) }
    end
    string.encode('UTF-8')
  end

  private

    def headers
      [
        I18n.t("admin.budget_investments.index.list.id"),
		I18n.t("admin.budget_investments.index.list.description"),
        I18n.t("admin.budget_investments.index.list.title"),
        I18n.t("admin.budget_investments.index.list.supports"),
        I18n.t("admin.budget_investments.index.list.physical_votes"),
        I18n.t("admin.budget_investments.index.list.total_votes"),
        I18n.t("admin.budget_investments.index.list.admin"),
        I18n.t("admin.budget_investments.index.list.valuator"),
        I18n.t("admin.budget_investments.index.list.valuation_group"),
        I18n.t("admin.budget_investments.index.list.geozone"),
        I18n.t("admin.budget_investments.index.list.feasibility"),
		I18n.t("admin.budget_investments.index.list.unfeasibility_explanation"),
        I18n.t("admin.budget_investments.index.list.price"),
		I18n.t("admin.budget_investments.index.list.price_explanation"),
        I18n.t("admin.budget_investments.index.list.valuation_finished"),
        I18n.t("admin.budget_investments.index.list.selected"),
		I18n.t("admin.budget_investments.index.list.winner"),
        I18n.t("admin.budget_investments.index.list.visible_to_valuators"),
        I18n.t("admin.budget_investments.index.list.author_username")
      ]
    end

    def csv_values(investment)
      [
        investment.id.to_s,
        investment.title,
		investment.description,
        investment.total_votes.to_s,
        investment.physical_final_votes_count,
        investment.final_total_votes,
        admin(investment),
        investment.assigned_valuators || "-",
        investment.assigned_valuation_groups || "-",
        investment.heading.name,
        I18n.t("admin.budget_investments.index.feasibility.#{investment.feasibility}"),
		investment.unfeasibility_explanation,
        investment.price,
		investment.price_explanation,
        investment.valuation_finished? ? I18n.t("shared.yes") : I18n.t("shared.no"),
        investment.selected? ? I18n.t("shared.yes") : I18n.t("shared.no"),
		investment.winner? ? I18n.t("shared.yes") : I18n.t("shared.no"),
        investment.visible_to_valuators? ? I18n.t("shared.yes") : I18n.t("shared.no"),
        investment.author.username
      ]
    end

    def admin(investment)
      if investment.administrator.present?
        investment.administrator.name
      else
        I18n.t("admin.budget_investments.index.no_admin_assigned")
      end
    end

    def price(investment)
      price_string = "admin.budget_investments.index.feasibility.#{investment.feasibility}"
      if investment.feasible?
        "#{I18n.t(price_string)} (#{investment.formatted_price})"
      else
        I18n.t(price_string)
      end
    end
end
