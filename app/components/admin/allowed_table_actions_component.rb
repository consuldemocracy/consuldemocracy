class Admin::AllowedTableActionsComponent < ApplicationComponent
  attr_reader :record, :options
  delegate :can?, to: :helpers
  delegate :action, to: :table_actions_component

  def initialize(record, **options)
    @record = record
    @options = options
  end

  private

    def actions
      (options[:actions] || [:edit, :destroy]).select { |action| can?(action, record) }
    end

    def table_actions_component
      @table_actions_component ||= Admin::TableActionsComponent.new(record, **options.merge(actions: actions))
    end
end
