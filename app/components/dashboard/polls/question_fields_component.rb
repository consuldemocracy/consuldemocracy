class Dashboard::Polls::QuestionFieldsComponent < ApplicationComponent
  attr_reader :form

  def initialize(form)
    @form = form
  end

  private

    def question
      form.object
    end

    def proposal
      question.proposal || question.poll.related
    end
end
