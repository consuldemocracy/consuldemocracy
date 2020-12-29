class Subscriptions::EditComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end
end
