class Problem < ActiveRecord::Base

  validates :title, presence: true
  validates :description, presence: true
  validates :summary, presence: true
  validates :call_to_action, presence: true

  has_and_belongs_to_many :geozones
  belongs_to :user
  has_many :proposals

  def geozones_name
    if self.geozones.any?
      names = ''
      self.geozones.each do |g|
        names += g.name + ' | '
      end
      return names
    else
      return 'Toda la comuna'
    end
  end


end
