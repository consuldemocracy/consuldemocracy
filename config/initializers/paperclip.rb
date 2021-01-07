if Rails.env.production? || Rails.env.staging? || Rails.env.preproduction?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_host_name] = Rails.application.secrets.aws_s3_host_name
  Paperclip::Attachment.default_options[:s3_protocol] = :https
  Paperclip::Attachment.default_options[:s3_credentials] = {
    access_key_id: Rails.application.secrets.aws_s3_access_key_id,
    secret_access_key: Rails.application.secrets.aws_s3_secret_access_key,
    s3_region: Rails.application.secrets.aws_s3_region
  }
  Paperclip::Attachment.default_options[:bucket] = Rails.application.secrets.aws_s3_bucket
  Paperclip::Attachment.default_options[:url] = ":s3_domain_url"
  Paperclip::Attachment.default_options[:path] = "/:class/:prefix/:style/:hash.:extension"
  Paperclip::Attachment.default_options[:hash_data] = ":class/:style"
  Paperclip::Attachment.default_options[:use_timestamp] = false
  Paperclip::Attachment.default_options[:hash_secret] = Rails.application.secrets.secret_key_base
end
