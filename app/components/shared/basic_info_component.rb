class Shared::BasicInfoComponent < ApplicationComponent
  attr_reader :record
  delegate :namespace, to: :helpers

  def initialize(record)
    @record = record
  end

  private

    def comments_path
      if namespace == "management"
        management_polymorphic_path(record, anchor: "comments")
      else
        polymorphic_path(record, anchor: "comments")
      end
    end

    def date
      time_tag record.created_at.to_date, format: :default
    end
end
