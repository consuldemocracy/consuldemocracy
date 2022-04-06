class SDGManagement::Relations::IndexComponent < ApplicationComponent
  include Header
  delegate :valid_filters, :current_filter, to: :helpers

  attr_reader :records

  def initialize(records)
    @records = records
  end

  private

    def title
      t("sdg_management.menu.#{model_class.table_name}")
    end

    def model_class
      records.model
    end

    def edit_path_for(record)
      {
        controller: "sdg_management/relations",
        action: :edit,
        relatable_type: record.class.name.tableize,
        id: record
      }
    end

    def search_label
      t("admin.shared.search.label.#{model_class.table_name}")
    end
end
