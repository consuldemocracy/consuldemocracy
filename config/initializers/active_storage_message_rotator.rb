# This code was copied from:
# https://github.com/hotwired/turbo-rails/blob/v1.4.0/UPGRADING.md#key-digest-changes-in-111
# Removing this code will make ActiveStorage image URLs generated with Rails 6.1
# or earlier inaccessible, causing images attached with CKEditor or linked from
# somewhere else not to be rendered.
Rails.application.config.after_initialize do |app|
  key_generator = ActiveSupport::KeyGenerator.new(
    app.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
  )

  app.message_verifier("ActiveStorage").rotate(key_generator.generate_key("ActiveStorage"))
end
