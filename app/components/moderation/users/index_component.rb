class Moderation::Users::IndexComponent < ApplicationComponent
  include Header

  attr_reader :users

  def initialize(users)
    @users = users
  end

  private

    def title
      t("moderation.users.index.title")
    end

    def status(user)
      t("admin.activity.show.actions.#{activity_action(user)}")
    end

    def activity_action(user)
      Activity.where(actionable: user, action: [:hide, :block]).last&.action || "block"
    end
end
