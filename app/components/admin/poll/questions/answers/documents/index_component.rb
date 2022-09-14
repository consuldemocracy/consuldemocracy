class Admin::Poll::Questions::Answers::Documents::IndexComponent < ApplicationComponent
  attr_reader :answer

  def initialize(answer)
    @answer = answer
  end
end
