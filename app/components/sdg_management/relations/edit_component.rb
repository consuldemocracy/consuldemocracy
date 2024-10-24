class SDGManagement::Relations::EditComponent < ApplicationComponent
  include Header

  attr_reader :record

  def initialize(record)
    @record = record
  end

  private

    def title
      @record.title
    end

    def update_path
      {
        controller: "sdg_management/relations",
        action: :update,
        relatable_type: record.class.name.tableize,
        id: record
      }
    end
end
