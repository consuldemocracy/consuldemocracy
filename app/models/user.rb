class User < ActiveRecord::Base
  has_many :debates

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def name
    "#{first_name} #{last_name}"
  end
end
