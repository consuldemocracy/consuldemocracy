require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord

  # Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_oauth(auth)
  Rails.logger.info('Attributes in auth.info:')
    auth.info.each do |key, value|
    Rails.logger.info("#{key}: #{value}")
  end

    oauth_email           = auth.info.email
    oauth_verified        = auth.info.verified || auth.info.verified_email || auth.info.email_verified || auth.extra.raw_info.email_verified
    oauth_email_confirmed = oauth_email.present? #&& oauth_verified
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed
Rails.logger.info("oauth_email #{oauth_email}")
Rails.logger.info("oauth_verified #{oauth_verified}")
Rails.logger.info("oauth_confirmed #{oauth_email_confirmed}")
Rails.logger.info("oauth_user #{oauth_user}")

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
  
  



# Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_saml(auth)

# Assuming 'auth.extra.raw_info' is the OneLogin::RubySaml::Attributes object
attributes = auth.extra.raw_info.attributes


# Define a mapping of attribute names to OID values
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

# Initialize a hash to store the extracted values
extracted_values = {}

# Iterate through the attribute mapping and extract values
attribute_mapping.each do |attribute_name, oid_value|
  if attributes[oid_value]
    extracted_values[attribute_name] = attributes[oid_value][0]
  end
end

# Now you have a hash containing the extracted values
Rails.logger.info("extracted values: #{extracted_values.inspect}")

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
   # oauth_email_confirmed = oauth_email.present? && (auth.info.verified || auth.info.verified_email)
   # oauth_lacode              = auth.extra.raw_info.all.dig("urn:oid:0.9.2342.19200300.100.1.17", 0).to_s
   # oauth_full_name           = auth.extra.raw_info.all.dig("urn:oid:0.9.2342.19200300.100.1.2", 0).to_s + "_" + auth.extra.raw_info.all.dig("urn:oid:0.9.2342.19200300.100.1.4", 0).to_s
   # Normalize the saml_postcode by stripping spaces and converting to lowercase
   normalized_saml_postcode = saml_postcode.strip.downcase if saml_postcode.present?

   
   #lacode comes from list of councils registered with IS
    oauth_lacode_ref          = "9079" # this should be picked up from secrets in future
    oauth_lacode_confirmed    = oauth_lacode == oauth_lacode_ref
    oauth_user            = User.find_by(email: saml_email) if saml_email_confirmed
   
   # Assign Geozone based on the normalized saml_postcode if it exists
   if normalized_saml_postcode.present?
   # Find the Postcode instance based on the normalized saml_postcode
   # This only goes in if Manage Postcodes is added
   #   postcode_instance = Postcode.find_by(postcode: normalized_saml_postcode)

   if postcode_instance
    # Assign the associated Geozone to the user
    #  saml_user.geozone = postcode_instance.geozone
   else
    # Handle the case when the postcode is not found
    #  saml_user.geozone = nil
  end
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



end
