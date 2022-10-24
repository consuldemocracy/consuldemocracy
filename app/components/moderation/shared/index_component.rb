class Moderation::Shared::IndexComponent < ApplicationComponent
  attr_reader :records

  def initialize(records)
    @records = records
  end

  private

    def i18n_namespace
      table_name
    end

    def field_name
      "#{records.model.model_name.singular}_ids[]"
    end

    def form_path
      url_for(
        request.query_parameters.merge(
          controller: "moderation/#{section_name}",
          action: "moderate",
          only_path: true
        )
      )
    end

    def table_name
      records.model.table_name
    end

    def section_name
      if table_name == "budget_investments"
        "budgets/investments"
      else
        table_name
      end
    end
end
