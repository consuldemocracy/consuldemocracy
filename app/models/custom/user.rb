load Rails.root.join("app", "models", "user.rb")

class User < ApplicationRecord

def self.unlock_in
     security = Tenant.current_secrets[:security]
     lockable = security[:lockable] if security
     unlock_in_value = lockable[:unlock_in] if lockable        
#     Rails.logger.info "Retrieved security: #{security.inspect}"    
#     Rails.logger.info "Retrieved lockable: #{lockable.inspect}"    
#     Rails.logger.info "Retrieved unlock_in: #{unlock_in_value.inspect}"        
     (unlock_in_value || 10).to_f.minutes
end

def send_devise_notification(notification, *)
     devise_mailer.send(notification, self, *).deliver_later
end


def erase(erase_reason = nil)
    update!(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      document_number: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil
    )
    identities.destroy_all
    remove_roles
  end


  # Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_oauth(auth)

    oauth_email           = auth.info.email
    oauth_verified        = auth.info.verified || auth.info.verified_email || auth.info.email_verified || auth.extra.raw_info.email_verified
    oauth_email_confirmed = oauth_email.present? #&& oauth_verified
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed


    oauth_user || User.new(
      username:  auth.info.name || auth.uid,
      email: oauth_email,
      oauth_email: oauth_email,
      password: Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at: oauth_email_confirmed ? DateTime.current : nil,
      verified_at: DateTime.current ,
      residence_verified_at:  DateTime.current
    )
  end
  
  
  def self.extract_saml_attributes(auth)
    # Define the attribute mapping here or in a constant
    attribute_mapping = {
      "saml_username" => "urn:oid:0.9.2342.19200300.100.1.1",
      "saml_authority_code" => "urn:oid:0.9.2342.19200300.100.1.17",
      "saml_firstname" => "urn:oid:0.9.2342.19200300.100.1.2",
      "saml_surname" => "urn:oid:0.9.2342.19200300.100.1.4",
      "saml_latitude" => "urn:oid:0.9.2342.19200300.100.1.33",
      "saml_longitude" => "urn:oid:0.9.2342.19200300.100.1.34",
      "saml_date_of_birth" => "urn:oid:0.9.2342.19200300.100.1.8",
      "saml_gender" => "urn:oid:0.9.2342.19200300.100.1.9",
      "saml_postcode" => "urn:oid:0.9.2342.19200300.100.1.16",
      "saml_email" => "urn:oid:0.9.2342.19200300.100.1.22",
      "saml_town" => "urn:oid:0.9.2342.19200300.100.1.15",
      "saml_add1" => "urn:oid:0.9.2342.19200300.100.1.12",
      "saml_5" => "urn:oid:0.9.2342.19200300.100.1.5",
      "saml_6" => "urn:oid:0.9.2342.19200300.100.1.6",
      "saml_7" => "urn:oid:0.9.2342.19200300.100.1.7",
      "saml_assurance" => "urn:oid:0.9.2342.19200300.100.1.20",
      "saml_10" => "urn:oid:0.9.2342.19200300.100.1.10"
    }

    # Assuming 'auth.extra.raw_info' is the OneLogin::RubySaml::Attributes object
    attributes = auth.extra.raw_info.attributes

    # Initialize a hash to store the extracted values
    extracted_values = {}

    # Iterate through the attribute mapping and extract values
    attribute_mapping.each do |attribute_name, oid_value|
      if attributes[oid_value]
        extracted_values[attribute_name] = attributes[oid_value][0]
      end
    end

    extracted_values
  end

  def self.first_or_initialize_for_saml(auth)
    extracted_values = self.extract_saml_attributes(auth)

   # Now you have a hash containing the extracted values
   #Rails.logger.info("extracted values: #{extracted_values.inspect}")


    # Assuming 'extracted_values' is the hash containing extracted values
    saml_username = extracted_values["saml_username"]
    saml_authority_code = extracted_values["saml_authority_code"]
    saml_firstname = extracted_values["saml_firstname"]
    saml_surname = extracted_values["saml_surname"]
    saml_long = extracted_values["saml_longitude"]
    saml_lat = extracted_values["saml_latitude"]
    saml_date_of_birth = extracted_values["saml_date_of_birth"]
    saml_gender = extracted_values["saml_gender"]
    saml_postcode = extracted_values["saml_postcode"]
    saml_email = extracted_values["saml_email"]
    saml_town = extracted_values["saml_town"]

    oauth_email = saml_email
    oauth_gender = saml_gender
    oauth_username = saml_username
    oauth_lacode = saml_authority_code      
    saml_full_name = saml_firstname + "_" + saml_surname
    oauth_date_of_birth = saml_date_of_birth
    oauth_email_confirmed = oauth_email.present?
    saml_email_confirmed = saml_email.present?

   # Normalize the saml_postcode by stripping spaces and converting to lowercase
    normalized_saml_postcode = saml_postcode.strip.downcase if saml_postcode.present?

    # Find existing user based on the current email (before potential update)
    existing_user = User.find_by(email: saml_email)
    # Find the Geozone ID for the new postcode
    new_geozone_id = Postcode.find_geozone_for_postcode(normalized_saml_postcode)
    # Update the user's geozone if it has changed (based on geozone ID comparison)
    if existing_user && new_geozone_id && new_geozone_id != existing_user.geozone_id
      existing_user.update(geozone_id: new_geozone_id)
      Rails.logger.info("User geozone updated to #{new_geozone_id}")
    end
   
   #lacode comes from list of councils registered with IS
    oauth_lacode_ref          = "9079" # this should be picked up from secrets in future
    oauth_lacode_confirmed    = oauth_lacode == oauth_lacode_ref
    oauth_user            = User.find_by(email: saml_email) if saml_email_confirmed
   
    # Initialize saml_geozone_id
    saml_geozone_id = nil
    # Assign Geozone based on the normalized saml_postcode if it exists
    if normalized_saml_postcode.present?  # Find the Postcode instance based on the normalized saml_postcode
      puts "about to check: #{normalized_saml_postcode}"
      saml_geozone_id = Postcode.find_geozone_for_postcode(normalized_saml_postcode)
   end

   
   # oauth_username = oauth_full_name ||  oauth_email.split("@").first || auth.info.name || auth.uid
   if saml_username.present? && saml_username != saml_email && saml_username != saml_full_name
      oauth_username = saml_username
   else
   # If the original value of oauth_username is the same as oauth_email or oauth_full_name, add a random number to obfuscate
      oauth_username = "#{saml_full_name}_#{rand(100..999)}"
   end
    oauth_user || User.new(
      username:  oauth_username,
      email: saml_email,
      date_of_birth: saml_date_of_birth,
      gender: saml_gender,
      password: Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at: DateTime.current,
      verified_at: DateTime.current ,
      residence_verified_at:  DateTime.current,
      geozone_id: saml_geozone_id
    )
  end


  # overwriting of Devise method to allow login using email OR username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    user = where(conditions.to_hash).find_by(["lower(email) = ?", login.downcase]) ||
    where(conditions.to_hash).find_by(["username = ?", login]) ||
    where(conditions.to_hash).find_by(["confirmed_phone = ?", login]) ||
    where(conditions.to_hash).find_by(["document_number = ?", login])

    if user.nil? && validate_document_number(login)
    # If no user is found and the login is a valid document, create a new user
      user=log_in_or_create_ys_user(login)
    end
  user
  end
  
  # Method to update user attributes based on SAML data
  def update_user_details_from_saml(auth)
   extracted_values = self.class.extract_saml_attributes(auth)

   # Now you have a hash containing the extracted values
    Rails.logger.info("extracted values: #{extracted_values.inspect}")
    saml_date_of_birth = extracted_values["saml_date_of_birth"]
    saml_gender = extracted_values["saml_gender"]
    saml_postcode = extracted_values["saml_postcode"]
     # Normalize the saml_postcode by stripping spaces and converting to lowercase
    normalized_saml_postcode = saml_postcode.strip.downcase if saml_postcode.present?

    # Find the Geozone ID for the new postcode
    new_geozone_id = Postcode.find_geozone_for_postcode(normalized_saml_postcode)

    # Check and update the user's details if they have changed
    self.geozone_id = new_geozone_id if geozone_id != new_geozone_id
    # Add more fields if necessary

    # Save only if any changes have been made
    save if changed?
  end


 private
  
  def self.log_in_or_create_ys_user(username)
    Rails.logger.info("YS inside log in or create")
  if existing_user = User.find_by(username: username)
    Rails.logger.info("YS Existing user")
    # Log in the existing user
    return existing_user # Assuming successful login
  else
    # Create a new user
    Rails.logger.info("Create YS - NOT EXISTING USER")
    ys_username = username
    ys_password = username
    ys_document_number = username
    ys_email = "#{username}@consul.dev"
    ys_confirmed_at = Time.now
#    ys_geozone = 1
    ys_geozone = Geozone.find_or_create_by(name: "ys").id
    Rails.logger.info("YS Trying to create new user")
    user = User.new(
      username: ys_username,
      email: ys_email,
      password: ys_password,
      geozone_id: ys_geozone,
      terms_of_service: "1",
      document_number: ys_document_number,
      confirmed_at: DateTime.current,
      verified_at: DateTime.current,
      residence_verified_at: DateTime.current
    )
    Rails.logger.info("User save errors: #{user.errors.full_messages.join(", ")}")
    Rails.logger.info("YS About to try to sign in the user #{user.inspect}")
    if user.save
    # If the user is created successfully, sign them in
    #sign_in user # Assuming you have access to the sign_in method
      Rails.logger.info("Create YS - USER created")
    else
      Rails.logger.info("Create YS - USER NOT created")
      Rails.logger.info("User save errors: #{user.errors.full_messages.join(", ")}")
    end
  end
  user
end


def self.validate_document_number(document_number)
      return true if document_number.nil?
      valid_prefixes = Rails.application.secrets.ys_prefixes || []
      if valid_prefixes.empty?
        Rails.logger.warn("No valid document prefixes found in secrets. Validation will fail.")
        return false
      end

      # Check if the document number is 16 digits long
      return false unless document_number.to_s.length == 16

      # Extract the prefix, middle, and suffix parts of the document number
      prefix = document_number.to_s[0, 6]
      middle = document_number.to_s[6, 8]
      suffix = document_number.to_s[14, 2]

      # Check if the prefix exists in the valid prefixes hash
      return false unless valid_prefixes.include?(prefix)

      # Check if the middle and suffix parts are numeric
      return false unless middle.match?(/\A\d{8}\z/) && suffix.match?(/\A\d{2}\z/)

      # If all criteria are met, return true
      Rails.logger.info("Document number is valid")
      true
  end



end
