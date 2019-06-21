module DownloadSettings
  module BudgetInvestmentCsv
    extend ActiveSupport::Concern

    def get_association_attribute_names
      ["author_name", "author_email"]
    end

    def get_downloadables_names(config)
      DownloadSetting.where(name_model: "Budget::Investment",
                            downloadable: true,
                            config: config).pluck(:name_field)
    end

    def to_csv(budgets, admin_attr, options = {})

      attributes = admin_attr.nil? ? [] : admin_attr

      CSV.generate(options) do |csv|
        csv << attributes
        budgets.each do |budget|
          csv << attributes.map{ |attr| budget.send(attr)}
        end
      end
    end

  end
end
