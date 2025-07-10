# This code is based on this gem https://github.com/jwickard/omniauth-wordpress-oauth2-plugin

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Wordpress < OmniAuth::Strategies::OAuth2
      option :name, "wordpress_oauth2"

      option :client_options, {}

      uid { raw_info["ID"] }

      info do
        {
            name: raw_info["display_name"],
            email: raw_info["user_email"],
            nickname: raw_info["user_nicename"],
            urls: { "Website" => raw_info["user_url"] }
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= obtain_raw_info
      end

      def obtain_raw_info
        access_token.get("/oauth/me", params: { "Authorization" => "Bearer #{access_token.token}" }).parsed
      end
    end
  end
end
