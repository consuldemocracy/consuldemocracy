class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question, :form, :disabled
  alias_method :disabled?, :disabled

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

    def answers_for_question
      form.object.answers[question.id] || []
    end

    def existing_answer
      answers_for_question.first&.answer
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
      html = label_tag("web_vote_option_#{option.id}") do
        input_tag(option) + option.title
      end
      html += open_text_tag(option) if option.allows_custom_text?
      html
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
      text_area_tag(
        "web_vote[#{question.id}][answer][#{option.id}]",
        existing_text_for(option),
        id: "web_vote_option_#{option.id}_text",
        disabled: disabled?,
        class: "open-text",
        maxlength: Poll::Answer.answer_max_length,
        rows: 1,
        "aria-label": t("poll_questions.open_text_aria_label", option: option.title),
        data: { selects: "web_vote_option_#{option.id}" }
      )
    end

    def existing_text_for(option)
      answer_for(option)&.answer.to_s
    end

    def checked?(option)
      answer_for(option).present?
    end

    def answer_for(option)
      answers_for_question.find { |a| a.option_id == option.id }
    end
end
