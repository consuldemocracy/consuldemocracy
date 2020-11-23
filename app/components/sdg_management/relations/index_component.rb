class SDGManagement::Relations::IndexComponent < ApplicationComponent
  include Header

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
end
