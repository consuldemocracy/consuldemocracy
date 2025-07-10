require 'httparty'
require 'omniauth'

module OmniAuth
  module Strategies
    class Codigo
      include OmniAuth::Strategy

      option :url_api, '/presupuestosparticipativos/codigos/api'
      option :url_formulario, '/presupuestosparticipativos/codigos/new'
      option :puerto, 8080

      def request_phase
        redirect options[:url_formulario]
      end

      def callback_phase
        clave = request['clave']
        valor = request['valor']

        respuesta_http = HTTParty.post( options[:url_api], :body => {:clave => clave, :valor => valor}.to_json, :headers => {'Content-Type' => 'application/json'} )
        respuesta_api_json = JSON.parse( respuesta_http.body )

        @user_info = {}

        logger = Logger.new(STDOUT)

        logger.debug(respuesta_api_json)   
        logger.debug(respuesta_api_json['id'])        

        if respuesta_api_json.key?("id")
          @user_info['invalid_credentials'] = false
          @user_info['uid']                 = respuesta_api_json['id']
          @user_info['document_number']     = respuesta_api_json['clave']
          @user_info['document_type']       = 1
          @user_info['name']                = respuesta_api_json['clave']
          @user_info['verified']            = true
        else
          @user_info['invalid_credentials'] = true
        end

        super
      end

      uid {
        @user_info['uid']
      }
      info {
        @user_info
      }

      def missing_credentials?
        request['username'].nil? or request['username'].empty? or request['password'].nil? or request['password'].empty?
      end
    end

  end
end
