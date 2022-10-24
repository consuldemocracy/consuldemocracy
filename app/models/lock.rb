class Lock < ApplicationRecord
  belongs_to :user

  before_save :set_locked_until

  def locked?
    locked_until > Time.current
  end

  def set_locked_until
    self.locked_until = lock_time if too_many_tries?
  end

  def lock_time
    Time.current + (2**tries).minutes
  end

  def too_many_tries?
    return false unless tries > 0

    tries % Lock.max_tries == 0
  end

  def self.increase_tries(user)
    find_or_create_by!(user: user).increment!(:tries).save!
  end

  def self.max_tries
    5
  end
end

# == Schema Information
#
# Table name: locks
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  tries        :integer          default(0)
#  locked_until :datetime         default(Sat, 01 Jan 2000 02:01:01 CET +01:00), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
