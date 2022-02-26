class Admin::Poll::Questions::Answers::TableActionsComponent < ApplicationComponent
  attr_reader :answer
  delegate :can?, to: :helpers

  def initialize(answer)
    @answer = answer
  end

  private

    def actions
      [:edit, :destroy].select { |action| can?(action, answer) }
    end
end
