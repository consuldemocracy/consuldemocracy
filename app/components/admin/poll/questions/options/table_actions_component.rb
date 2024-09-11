class Admin::Poll::Questions::Options::TableActionsComponent < ApplicationComponent
  attr_reader :option

  def initialize(option)
    @option = option
  end
end
