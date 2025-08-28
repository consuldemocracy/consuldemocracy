class Polls::AccessStatusComponent < ApplicationComponent
  attr_reader :poll
  use_helpers :cannot?, :current_user

  def initialize(poll)
    @poll = poll
  end

  def render?
    attributes.present?
  end

  private

    def text
      attributes[:text]
    end

    def html_class
      attributes[:class]
    end

    def attributes
      if current_user
        if current_user.unverified?
          { text: t("polls.index.unverified"), class: "unverified" }
        elsif cannot?(:answer, poll)
          { text: t("polls.index.cant_answer"), class: "cant-answer" }
        elsif !poll.votable_by?(current_user)
          { text: t("polls.index.already_answer"), class: "already-answer" }
        end
      else
        { text: t("polls.index.not_logged_in"), class: "not-logged-in" }
      end
    end
end
