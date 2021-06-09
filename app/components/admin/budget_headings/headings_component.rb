class Admin::BudgetHeadings::HeadingsComponent < ApplicationComponent
  attr_reader :headings

  def initialize(headings)
    @headings = headings
  end

  private

    def group
      @group ||= headings.first.group
    end

    def budget
      @budget ||= headings.first.budget
    end
end
