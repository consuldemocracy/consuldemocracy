class Shared::DetailedInfoComponent < ApplicationComponent
  attr_reader :record, :comments_path, :preview
  alias_method :preview?, :preview

  def initialize(record, comments_path: "#comments", preview: false)
    @record = record
    @comments_path = comments_path
    @preview = preview
  end

  private

    def date
      time_tag record.created_at.to_date, format: :default
    end
end
