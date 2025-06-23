class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question
  use_helpers :can?, :current_user

  def initialize(question)
    @question = question
  end

  private

    def options_read_more_links
      safe_join(question.options_with_read_more.map do |option|
        link_to option.title, "#option_#{option.id}"
      end, ", ")
    end

    def multiple_choice?
      question.max_votes > 1
    end

    def disabled_attribute
      "disabled='disabled'" unless can?(:answer, question.poll)
    end

    def multiple_choice_help_text
      tag.span(
        t("poll_questions.description.#{question.vote_type}", maximum: question.max_votes),
        class: "help-text"
      )
    end

    def multiple_choice_field(option)
      choice_field(option) do
        check_box_tag "web_vote[#{question.id}][option_id][]",
                      option.id,
                      checked?(option),
                      id: "web_vote_option_#{option.id}"
      end
    end

    def single_choice_field(option)
      choice_field(option) do
        radio_button_tag "web_vote[#{question.id}][option_id]",
                         option.id,
                         checked?(option),
                         id: "web_vote_option_#{option.id}"
      end
    end

    def choice_field(option, &block)
      label_tag("web_vote_option_#{option.id}") do
        block.call + option.title
      end
    end

    def checked?(option)
      question.answers.where(author: current_user, option: option).any?
    end
end
