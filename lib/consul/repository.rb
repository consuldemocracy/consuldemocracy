module Consul
  module Repository
    class << self
      # This URL will be used to deploy your source code with Capistrano.
      # In order to comply with the AGPL, a link to this URL will also be
      # automatically added to the footer, alongside other legal links
      # like terms and conditions.
      #
      # By default, it uses the Consul Democracy repository. Change this
      # method in order to deploy code from your own repository (for
      # instance, your fork of the Consul Democracy repository).
      #
      # Remember that, to comply with the AGPL, any person visiting your
      # website must also have (read) access to your source code.
      def url
        consul_url
      end

      private

        def consul_url
          "https://github.com/consuldemocracy/consuldemocracy.git"
        end
    end
  end
end
