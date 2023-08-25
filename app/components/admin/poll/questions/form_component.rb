class Admin::Poll::Questions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :question, :url
  delegate :can?, to: :helpers

  def initialize(question, url:)
    @question = question
    @url = url
  end

  private

    def select_options
      Poll.all.select { |poll| can?(:create, Poll::Question.new(poll: poll)) }.map do |poll|
        [poll.name, poll.id]
      end
    end
end
