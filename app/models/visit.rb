class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user

  def user_id=(v)
    self.user_id = nil
  end
end
