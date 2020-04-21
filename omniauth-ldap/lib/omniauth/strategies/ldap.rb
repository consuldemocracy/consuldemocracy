require 'omniauth'

module OmniAuth
  module Strategies
    class LDAP
      include OmniAuth::Strategy
      @@config = {
        'name' => 'cn',
        'first_name' => 'givenName',
        'last_name' => 'sn',
        'email' => ['mail', "email", 'userPrincipalName'],
        'phone' => ['telephoneNumber', 'homePhone', 'facsimileTelephoneNumber'],
        'mobile' => ['mobile', 'mobileTelephoneNumber'],
        'nickname' => ['uid', 'userid', 'sAMAccountName'],
        'title' => 'title',
        'location' => {"%0, %1, %2, %3 %4" => [['address', 'postalAddress', 'homePostalAddress', 'street', 'streetAddress'], ['l'], ['st'],['co'],['postOfficeBox']]},
        'uid' => 'dn',
        'url' => ['wwwhomepage'],
        'image' => 'jpegPhoto',
        'description' => 'description'
      }
      option :title, "LDAP Authentication" #default title for authentication form
      option :port, 389
      option :method, :plain
      option :uid, 'sAMAccountName'
      option :name_proc, lambda {|n| n}
      option :url, '/presupuestosparticipativos/ldap/new'


      def request_phase

        OmniAuth::LDAP::Adaptor.validate @options
	redirect options[:url]

      end

      def callback_phase

        @adaptor = OmniAuth::LDAP::Adaptor.new @options
	
        return fail!(:missing_credentials) if missing_credentials?

	begin

          @ldap_user_info = @adaptor.bind_as(:filter => filter(@adaptor), :size => 1, :password => request['password'])

	  if !@ldap_user_info
            @user_info = {}
            @user_info['invalid_credentials'] = true
          else
            @user_info = self.class.map_user(@@config, @ldap_user_info)
          end

	  super

        rescue Exception => e
          return fail!(:ldap_error, e)
	end

      end

      def filter adaptor

        if adaptor.filter and !adaptor.filter.empty?
          Net::LDAP::Filter.construct(adaptor.filter % {username: @options[:name_proc].call(request['username'])})
        else
          Net::LDAP::Filter.eq(adaptor.uid, @options[:name_proc].call(request['username']))
        end

      end

      uid {
        @user_info["uid"]
      }
      info {
        @user_info
      }
      extra {
        { :raw_info => @ldap_user_info }
      }

      def self.map_user(mapper, object)
        user = {}
        mapper.each do |key, value|
          case value
          when String
            user[key] = object[value.downcase.to_sym].first if object.respond_to? value.downcase.to_sym
          when Array
            value.each {|v| (user[key] = object[v.downcase.to_sym].first; break;) if object.respond_to? v.downcase.to_sym}
          when Hash
            value.map do |key1, value1|
              pattern = key1.dup
              value1.each_with_index do |v,i|
                part = ''; v.collect(&:downcase).collect(&:to_sym).each {|v1| (part = object[v1].first; break;) if object.respond_to? v1}
                pattern.gsub!("%#{i}",part||'')
              end
              user[key] = pattern
            end
          end
        end
        user
      end

      protected

      def missing_credentials?
        request['username'].nil? or request['username'].empty? or request['password'].nil? or request['password'].empty?
      end # missing_credentials?
    end
  end
end

OmniAuth.config.add_camelization 'ldap', 'LDAP'
