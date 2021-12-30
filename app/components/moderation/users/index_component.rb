class Moderation::Users::IndexComponent < ApplicationComponent
  attr_reader :users

  def initialize(users)
    @users = users
  end
end
