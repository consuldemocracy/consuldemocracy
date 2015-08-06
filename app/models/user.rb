class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true, unless: :use_nickname?
  validates :last_name, presence: true, unless: :use_nickname?
  validates :nickname, presence: true, if: :use_nickname?

  def name
    use_nickname? ? nickname : "#{first_name} #{last_name}"
  end
end
