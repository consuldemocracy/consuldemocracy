class Admin::Poll::Questions::Answers::Documents::TableActionsComponent < ApplicationComponent
  attr_reader :document
  delegate :can?, to: :helpers

  def initialize(document)
    @document = document
  end

  private

    def actions
      [:destroy].select { |action| can?(action, document) }
    end
end
