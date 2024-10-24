class Shared::ModerationActionsComponent < ApplicationComponent
  attr_reader :record
  use_helpers :can?

  def initialize(record)
    @record = record
  end

  def render?
    can?(:hide, record) || can?(:hide, author)
  end

  private

    def author
      record.author
    end

    def hide_path
      polymorphic_path([:moderation, record], action: :hide)
    end
end
