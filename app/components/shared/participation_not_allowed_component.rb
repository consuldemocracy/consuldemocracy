class Shared::ParticipationNotAllowedComponent < ApplicationComponent
  attr_reader :votable, :cannot_vote_text
  delegate :current_user, :link_to_signin, :link_to_signup, to: :helpers

  def initialize(votable, cannot_vote_text:)
    @votable = votable
    @cannot_vote_text = cannot_vote_text
  end

  def render?
    body.present?
  end

  private

    def body
      @body ||=
        if !current_user
          sanitize(t("users.login_to_continue", signin: link_to_signin, signup: link_to_signup))
        elsif organization?
          tag.p t("votes.organizations")
        elsif cannot_vote_text.present?
          tag.p sanitize(cannot_vote_text)
        end
    end

    def organization?
      current_user&.organization?
    end
end
