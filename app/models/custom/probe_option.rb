class ProbeOption < ActiveRecord::Base
  belongs_to :probe
  has_many :probe_selections

  def original_image_url
    "/docs/#{probe.codename}/#{code}_#{name.parameterize.underscore}.jpg"
  end

  def thumb_image_url
    "#{probe.codename}/#{code}_#{name.parameterize.underscore}_thumb.jpg"
  end

  def pdf_url
    "/docs/#{probe.codename}/#{code}_dossier_#{name.parameterize.underscore}.pdf"
  end

  def pdf_title
    "Dossier #{name} (PDF | #{pdf_size})"
  end

  def pdf_size
    if File.exist?("#{Rails.root}/public/#{pdf_url}")
      helper = Object.new.extend(ActionView::Helpers::NumberHelper)
      helper.number_to_human_size(File.size("#{Rails.root}/public#{pdf_url}"), precision: 3)
    end
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
end