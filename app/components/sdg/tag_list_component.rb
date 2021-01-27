class SDG::TagListComponent < ApplicationComponent
  attr_reader :record, :limit

  def initialize(record, limit: nil)
    @record = record
    @limit = limit
  end
end
