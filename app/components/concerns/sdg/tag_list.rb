module SDG::TagList
  extend ActiveSupport::Concern
  attr_reader :record, :limit

  def initialize(record, limit: nil)
    @record = record
    @limit = limit
  end

  def render?
    SDG::ProcessEnabled.new(record).enabled?
  end

  def tag_records
    tags = record.send(association_name)

    if tags.respond_to?(:limit)
      tags.order(:code).limit(limit)
    else
      tags.sort[0..(limit.to_i - 1)]
    end
  end

  def see_more_link
    render Shared::SeeMoreLinkComponent.new(record, association_name, limit: limit)
  end

  def association_name
    raise NotImplementedError, "method must be implemented in the included class"
  end
end
