class Ability
  include CanCan::Ability

  def initialize(user)
    # If someone can hide something, he can also hide it
    # from the moderation screen
    alias_action :hide_in_moderation_screen, to: :hide

    if user # logged-in users
      if user.administrator?
        self.merge Abilities::Administrator.new(user)
      elsif user.moderator?
        self.merge Abilities::Moderator.new(user)
      else
        self.merge Abilities::Common.new(user)
      end
    else
      self.merge Abilities::Everyone.new(user)
    end
  end

end
