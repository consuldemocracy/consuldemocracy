class DirectMessage < ActiveRecord::Base
  belongs_to :sender,   class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
end
