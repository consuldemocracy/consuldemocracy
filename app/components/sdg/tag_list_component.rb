class SDG::TagListComponent < ApplicationComponent
  attr_reader :record, :limit, :linkable

  def initialize(record, limit: nil, linkable: true)
    @record = record
    @limit = limit
    @linkable = linkable
  end

  private

    def goals_list
      if linkable
        render SDG::Goals::TagListComponent.new(record, limit: limit)
      else
        render SDG::Goals::PlainTagListComponent.new(record, limit: limit)
      end
    end

    def targets_list
      if linkable
        render SDG::Targets::TagListComponent.new(record, limit: limit)
      else
        render SDG::Targets::PlainTagListComponent.new(record, limit: limit)
      end
    end
end
