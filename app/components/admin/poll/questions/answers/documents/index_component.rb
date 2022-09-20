class Admin::Poll::Questions::Answers::Documents::IndexComponent < ApplicationComponent
  attr_reader :answer
  delegate :can?, to: :helpers

  def initialize(answer)
    @answer = answer
  end

  private

    def documents
      @documents ||= @answer.class.find(@answer.id).documents
    end
end
