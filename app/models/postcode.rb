class Postcode < ApplicationRecord
  include Graphqlable

  belongs_to :geozone
  validates :postcode, presence: true
  scope :public_for_api, -> { all }

  def self.names
    Postcode.pluck(:postcode)
  end

  def self.find_by_normalized_postcode(postcode)
    normalized_postcode = postcode.gsub(/\s+/, '').downcase
    where("REPLACE(LOWER(postcode), ' ', '') = ?", normalized_postcode).first
  end


  def safe_to_destroy?
    Postcode.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(name: self).empty?
    end
  end

  def human_name
  end

   def valid_postal_code?
      return true if Setting["postal_codes"].blank?

      Setting["postal_codes"].split(",").any? do |code_or_range|
        if code_or_range.include?(":")
          Range.new(*code_or_range.split(":").map(&:strip)).include?(postal_code&.strip)
        else
          /\A#{code_or_range.strip}\Z/.match?(postal_code&.strip)
        end
      end
    end

  def self.find_geozone_for_postcode(postcode)
    normalized_postcode = postcode.strip.gsub(/\s+/, '').downcase
    puts "About to compare Normalized Postcode: #{normalized_postcode}"
    # Check for exact match
    exact_match = find_by_exact_postcode(normalized_postcode)
    return exact_match.geozone_id if exact_match

    # Check for range match
    range_match = find_by_range_containing(normalized_postcode)
    range_match&.geozone_id
  end

  private

  # Finds an exact match for an individual postcode
  def self.find_by_exact_postcode(postcode)
    where("REPLACE(LOWER(postcode), ' ', '') = ?", postcode).first
  end

 def self.find_by_range_containing(postcode)
  normalized_postcode = postcode.strip.gsub(/\s+/, '').downcase

  # Fetch all postcode ranges from the database, sorted by start
  all_ranges = where("postcode LIKE ?", '%:%').order(:postcode)

  # Perform binary search to find the appropriate range
  left, right = 0, all_ranges.size - 1
  while left <= right
    mid = (left + right) / 2
    range_record = all_ranges[mid]
    range_start, range_end = range_record.postcode.gsub(/\s+/, '').downcase.split(":")

    if range_start <= normalized_postcode && normalized_postcode <= range_end
      return range_record
    elsif range_start > normalized_postcode
      right = mid - 1
    else
      left = mid + 1
    end
  end

  # No matching range found
  nil
end

end