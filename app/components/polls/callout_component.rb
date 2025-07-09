class Polls::CalloutComponent < ApplicationComponent
  attr_reader :poll
  use_helpers :can?, :current_user, :link_to_signin, :link_to_signup

  def initialize(poll)
    @poll = poll
  end

  private

    def voted_in_booth?
      poll.voted_in_booth?(current_user)
    end

    def voted_in_web?
      poll.voted_in_web?(current_user)
    end

    def voted_blank?
      poll.answers.where(author: current_user).none?
    end

    def callout(text, html_class: "warning")
      tag.div(text, class: "callout #{html_class}")
    end

    def not_logged_in_text
      sanitize(t("polls.show.cant_answer_not_logged_in",
                 signin: link_to_signin,
                 signup: link_to_signup))
    end

    def unverified_text
      sanitize(t("polls.show.cant_answer_verify",
                 verify_link: link_to(t("polls.show.verify_link"), verification_path)))
    end
end
