class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question, :form, :disabled
  alias_method :disabled?, :disabled
  use_helpers :current_user

  def initialize(question, form:, disabled: false)
    @question = question
    @form = form
    @disabled = disabled
  end

  private

    def fieldset_attributes
      tag.attributes(
        id: dom_id(question),
        disabled: ("disabled" if disabled?),
        class: fieldset_class,
        data: { max_votes: question.max_votes }
      )
    end

    def fieldset_class
      if multiple_choice?
        "multiple-choice"
      else
        "single-choice"
      end
    end

    def options_read_more_links
      safe_join(question.options_with_read_more.map do |option|
        link_to option.title, "#option_#{option.id}"
      end, ", ")
    end

    def existing_answer
      answer = question.answers.where(author: current_user).first
      return answer.text_answer if answer&.text_answer?

      ""
    end

    def multiple_choice?
      question.multiple?
    end

    def multiple_choice_help_text
      tag.span(
        t("poll_questions.description.multiple", maximum: question.max_votes),
        class: "help-text"
      )
    end

    def choice_field(option)
      label_tag("web_vote_option_#{option.id}") do
        html = input_tag(option) + option.title
        html += open_text_tag(option) if option.open_text?
        html
      end
    end

    def input_tag(option)
      if multiple_choice?
        check_box_tag "web_vote[#{question.id}][option_id][]",
                      option.id,
                      checked?(option),
                      id: "web_vote_option_#{option.id}"
      else
        radio_button_tag "web_vote[#{question.id}][option_id]",
                         option.id,
                         checked?(option),
                         id: "web_vote_option_#{option.id}"
      end
    end

    def open_text_tag(option)
      text_field_tag(
        "web_vote[#{question.id}][text_answer][#{option.id}]",
        existing_text_for(option),
        id: "web_vote_option_#{option.id}_text",
        disabled: disabled?,
        class: "open-text",
        data: { selects: "web_vote_option_#{option.id}" }
      )
    end

    def existing_text_for(option)
      answer = question.answers.where(author: current_user, option: option).first
      return answer.text_answer if answer&.text_answer?

      ""
    end

    def checked?(option)
      form.object.answers[question.id].find { |answer| answer.option_id == option.id }
    end
end
