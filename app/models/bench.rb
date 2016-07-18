class Bench < ActiveRecord::Base
  acts_as_votable

  def original_image_url
    "/docs/town_planning/#{code}_#{name.parameterize.underscore}.jpg"
  end

  def thumb_image_url
    "town_planning/#{code}_#{name.parameterize.underscore}_thumb.jpg"
  end

  def pdf_url
    "/docs/town_planning/#{code}_dossier_#{name.parameterize.underscore}.pdf"
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

  def register_vote(user, vote_value)
    if votable_by?(user)
      remove_previous_votes(user)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def remove_previous_votes(user)
    user.votes.up.for_type(Bench).destroy_all
  end

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def self.voted_by(user)
    user.votes.for_type(Bench).last.votable
  end

end