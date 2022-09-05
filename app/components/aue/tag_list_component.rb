class AUE::TagListComponent < ApplicationComponent
  attr_reader :record, :limit, :linkable

  def initialize(record, limit: nil, linkable: true)
    @record = record
    @limit = limit
    @linkable = linkable
  end

  def render?
    record.aue_goals.any? || record.aue_local_goals.any?
  end

  private

    def goals_list
      render AUE::Goals::PlainTagListComponent.new(record, limit: limit)
    end

    def local_goals_list
      render AUE::LocalGoals::TagListComponent.new(record, limit: limit)
    end
end
