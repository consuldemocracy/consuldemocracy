require_dependency Rails.root.join('app', 'models', 'user').to_s

class User

  has_many :meetings

  before_validation :normalize_email

  scope :accepted_newsletter, -> { where(newsletter: true) }
  scope :rejected_newsletter, -> { where(newsletter: false) }

  EXPORT_COLUMNS = %i{ email subject body username newsletter}
  EXPORT_COLUMN_NAMES = { email: 'RECEPTOR', subject: 'ASUNTO', body: 'CUERPO',  username: 'NOMBRE_USUARIO', newsletter: 'ACEPTA_ENVIO_NOTICIAS'}

  def downgrade_verification_level
    update_column(:verified_at, nil)
    update_column(:residence_verified_at, nil)
    update_column(:census_removed_at, Time.current)
  end

  def upgrade_verification_level_from_downgrade
    update_column(:verified_at, Time.now)
    update_column(:residence_verified_at, Time.now)
    update_column(:census_removed_at, nil)
  end

  def normalize_email
    return unless self.email
    if self.email.include?('+') && self.email.include?('@')
      name, domain = self.email.split('@')
      valid_part, _ = name.split('+')
      self.email = "#{valid_part}@#{domain}"
    end
  end


  def to_param
    username
  end

  def self.find_by_param(input)
    find_by_username(input)
  end

  def self.to_csv
    CSV.generate(headers: true, col_sep: "\t", encoding: Encoding::UTF_8) do |csv|
      cols = self::EXPORT_COLUMNS.flatten.collect { |col| self::EXPORT_COLUMN_NAMES[col] }
      csv << cols
      all.find_each do |user|
        csv << self::EXPORT_COLUMNS.map do |attr|
          case attr
            when :subject
              ""
            when :body
              ""
            when :newsletter
              if user.newsletter
                "si"
              else
                "no"
              end
            else
              user.try(attr)
          end
        end
      end
    end
  end

end
