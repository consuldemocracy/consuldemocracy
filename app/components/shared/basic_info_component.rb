class Shared::BasicInfoComponent < ApplicationComponent
  attr_reader :record
  use_helpers :namespace

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
end
