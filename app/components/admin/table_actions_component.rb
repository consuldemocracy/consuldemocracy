class Admin::TableActionsComponent < ApplicationComponent
  attr_reader :record, :actions

  def initialize(record, actions: [:edit, :destroy])
    @record = record
    @actions = actions
  end
end
