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

# This code was copied from:
# https://guides.rubyonrails.org/v7.0/upgrading_ruby_on_rails.html#key-generator-digest-class-changing-to-use-sha256
# TODO: safe to remove after upgrading to Rails 7.1 or releasing a new
# version of Consul Democracy
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
