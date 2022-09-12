class PhysicalFinalVote < ApplicationRecord
  include Filterable
  include Randomizable
  
  SORTING_OPTIONS = { id: "id"}.freeze
  belongs_to :signable, foreign_key: 'signable_id', class_name: "Budget::Investment"	
  
  scope :by_booth,          ->(booth)    { where("booth ilike ?", "%#{booth}%") }
  scope :by_budget,          ->(budget)    { joins(signable: :translations).where(signable_type: 'Budget::Investment').where("budget_investments.budget_id = ?", budget) }
  scope :by_title_or_id,	->(title_or_id)	{joins(signable: :translations).where(signable_type: 'Budget::Investment').where("budget_investment_translations.title ilike ?", "%#{title_or_id}%").or(joins(signable: :translations).where(signable_id: title_or_id ))}
  def signable
     return unless signable_type == "Budget::Investment"
     super
   end
  VALID_SIGNABLES = %w[Budget::Investment].freeze

  validates :booth, presence: true
  validates :total_votes, presence: true
  validates :signable_type, inclusion: { in: VALID_SIGNABLES }

  def name
    "#{signable.title}" + " [#{signable.id}]"
  end

  def signable_name
    I18n.t("activerecord.models.#{signable_type.underscore}", count: 1)
  end

  def signable_found
    errors.add(:signable_id, :not_found) if errors.messages[:signable].present?
  end
  def self.order_filter(params)
      sorting_key = params[:sort_by]&.downcase&.to_sym
      allowed_sort_option = SORTING_OPTIONS[sorting_key]
      direction = params[:direction] == "asc" ? "asc" : "desc"

      if allowed_sort_option.present?
        order("#{allowed_sort_option} #{direction}")
      else sorting_key == :title
        direction == "asc" ? sort_by_title : sort_by_title.reverse
      #else
      #  order(cached_votes_up: :desc).order(id: :desc)
      end
    end
    def self.sort_by_title
      all.sort_by(&:id)
    end

  def self.apply_filters_and_search(params, current_filter = nil)
      physical_final_votes = all
      physical_final_votes = physical_final_votes.send(current_filter)             if current_filter.present?
      physical_final_votes = physical_final_votes.by_heading(params[:heading_id])  if params[:heading_id].present?
      physical_final_votes = physical_final_votes.search(params[:search])          if params[:search].present?
      physical_final_votes = physical_final_votes.filter(params[:advanced_search]) if params[:advanced_search].present?
      physical_final_votes
	end
	def self.search(terms)
      pg_search(terms)
    end
	def self.scoped_filter(params, current_filter)
	  results = all
	  results = results.by_booth(params[:booth].strip)  if params[:booth].present?
	  results = results.by_title_or_id(params[:title_or_id].strip)  if params[:title_or_id].present?
	  results = results.by_budget(params[:budget_id].strip)  if params[:budget_id].present?
	  results = advanced_filters(params, results)                          if params[:advanced_filters].present?

	  results = results.send(current_filter) if current_filter.present?
	  results
	end
end
