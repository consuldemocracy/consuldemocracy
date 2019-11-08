require "csv"

class LocalCensusRecords::Import
  include ActiveModel::Model

  ATTRIBUTES = %w[document_type document_number date_of_birth postal_code].freeze
  ALLOWED_FILE_EXTENSIONS = %w[csv].freeze

  attr_accessor :file, :created_records, :invalid_records

  validates :file, presence: true
  validate :file_extension, if: -> { @file.present? }
  validate :file_headers_definition, if: -> { @file.present? && valid_extension? }

  def initialize(attributes = {})
    if attributes.present?
      attributes.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
    @created_records = []
    @invalid_records = []
  end

  def save
    return false if invalid?

    CSV.open(file.path, headers: true).each do |row|
      next if empty_row?(row)

      process_row row
    end
    true
  end

  def save!
    validate! && save
  end

  private

    def process_row(row)
      local_census_record = build_local_census_record(row)

      if local_census_record.invalid?
        invalid_records << local_census_record
      else
        local_census_record.save!
        created_records << local_census_record
      end
    end

    def build_local_census_record(row)
      local_census_record = LocalCensusRecord.new
      local_census_record.attributes = row.to_hash.slice(*ATTRIBUTES)
      local_census_record
    end

    def empty_row?(row)
      row.all? { |_, cell| cell.nil? }
    end

    def file_extension
      return if valid_extension?

      errors.add :file, :extension, valid_extensions: ALLOWED_FILE_EXTENSIONS.join(", ")
    end

    def fetch_file_headers
      CSV.open(file.path, &:readline)
    end

    def file_headers_definition
      headers = fetch_file_headers
      return if headers.all? { |header| ATTRIBUTES.include? header } &&
        ATTRIBUTES.all? { |attr| headers.include? attr }

      errors.add :file, :headers, required_headers: ATTRIBUTES.join(", ")
    end

    def valid_extension?
      ALLOWED_FILE_EXTENSIONS.include? extension
    end

    def extension
      File.extname(file.original_filename).delete(".")
    end
end
