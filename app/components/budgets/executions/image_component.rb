class Budgets::Executions::ImageComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :image_path_for

  def initialize(investment)
    @investment = investment
  end

  private

    def milestone
      investment.milestones.where.associated(:image).order_by_publication_date.last
    end

    def image
      milestone&.image || investment.image
    end
end
