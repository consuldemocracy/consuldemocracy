class Interest < ActiveRecord::Base
  belongs_to :user
  belongs_to :interestable, polymorphic: true
  
end
