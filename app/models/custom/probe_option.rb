class ProbeOption < ActiveRecord::Base
  include Randomizable

  belongs_to :probe
  belongs_to :debate
  has_many :probe_selections
  has_many :comments, as: :commentable

  scope :with_hidden, -> { all }

  def path
    probe_probe_option_path(probe_id: probe.codename, id: id)
  end

  def original_image_url
    "/docs/#{probe.codename}/#{code}_#{param_name}.jpg"
  end

  def thumb_image_url
    "/docs/#{probe.codename}/#{code}_#{param_name}_thumb.jpg"
  end

  def file_path(ref, extension)
    "/docs/#{probe.codename}/#{code}_#{ref}_#{param_name}.#{extension}"
  end

  def file_size(ref, extension)
    if File.exist?("#{Rails.root}/public/#{file_path(ref, extension)}")
      helper = Object.new.extend(ActionView::Helpers::NumberHelper)
      helper.number_to_human_size(File.size("#{Rails.root}/public#{file_path(ref, extension)}"), precision: 3)
    end
  end

  def param_name
    @param_name ||= name.parameterize.underscore
  end

  def select(user)
    if selectable_by?(user)
      selection = ProbeSelection.find_or_create_by(user_id: user.id, probe_id: probe.id)
      selection.update(probe_option_id: id)
    end
  end

  def selectable_by?(user)
    probe.selecting_allowed && user && user.level_two_or_three_verified?
  end

  def to_param
    "#{id}-#{name}".parameterize
  end

  def title
    self.name
  end

  def hidden?
    false
  end

end
