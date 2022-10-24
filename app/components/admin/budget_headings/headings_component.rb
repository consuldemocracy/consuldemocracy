class Admin::BudgetHeadings::HeadingsComponent < ApplicationComponent
  attr_reader :headings

  def initialize(headings)
    @headings = headings
  end

  private

    def group
      @group ||= headings.proxy_association.owner
    end

    def budget
      @budget ||= group.budget
    end
end
