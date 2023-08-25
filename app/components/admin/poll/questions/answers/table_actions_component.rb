class Admin::Poll::Questions::Answers::TableActionsComponent < ApplicationComponent
  attr_reader :answer

  def initialize(answer)
    @answer = answer
  end
end
