class Admin::BudgetHeadings::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :heading, :path, :action

  def initialize(heading, path:, action:)
    @heading = heading
    @path = path
    @action = action
  end

  private

    def budget
      heading.budget
    end

    def single_heading?
      helpers.respond_to?(:single_heading?) && helpers.single_heading?
    end
end
