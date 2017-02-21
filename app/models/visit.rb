class Visit < ActiveRecord::Base

  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user

  def user=(value)
    write_attribute(:user_id,  nil)
  end
end
