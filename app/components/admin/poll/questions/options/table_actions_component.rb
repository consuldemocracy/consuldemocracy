class Admin::Poll::Questions::Options::TableActionsComponent < ApplicationComponent
  attr_reader :option, :actions

  def initialize(option)
    @option = option
    if option.question.essay?
      @actions = [:edit]
    else
      @actions = [:edit, :destroy]
    end
  end
end
