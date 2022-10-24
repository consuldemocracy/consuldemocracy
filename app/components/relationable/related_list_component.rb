class Relationable::RelatedListComponent < ApplicationComponent
  attr_reader :relationable
  delegate :current_user, to: :helpers

  def initialize(relationable)
    @relationable = relationable
  end

  def render?
    related_contents.present?
  end

  private

    def related_contents
      @related_contents ||= Kaminari.paginate_array(relationable.relationed_contents).page(params[:page]).per(5)
    end
end
