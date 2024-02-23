class Admin::Poll::Questions::Answers::Documents::IndexComponent < ApplicationComponent
  attr_reader :answer
  use_helpers :can?

  def initialize(answer)
    @answer = answer
  end

  private

    def documents
      @documents ||= @answer.class.find(@answer.id).documents
    end
end
