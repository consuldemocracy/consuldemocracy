require 'base64'
require 'json'

class ParticipacionTokenStrategy < Warden::Strategies::Base
  def valid?
    token.present?
  end

  def authenticate!
    # El usuario externo que tenemos registrado...
    eu = ExternalUser.get(token)
    # Deberíamos localizar el usuario por email y si no existe.. es cuando lo crearíamos
    if(eu)
      # No podemos tener emails duplicados en consul, asi que buscamos primero por el email,
      # si es que la cuenta externa tiene email, si no lo tiene intentamos buscar por
      # el id de participación que ese seguro si lo tenemos; y sino creamos la cuenta
      if(eu.email != nil)
        u = User.find_by(email: eu.email)
      else
        u = User.find_by(participacion_id: eu.participacion_id)
      end

      if(u)
        u.participacion_id = eu.participacion_id
        hasChanges = false
        if(eu.fullname != u.username)
          u.username = eu.fullname
          hasChanges = true
        end
        if(eu.validated && !u.level_three_verified?)
          u.verified_at = DateTime.current
          hasChanges = true
        end
        if(eu.organization)
          if(!u.organization?)
            u.organization= toOrganization(eu)
          else
            u.organization.name = eu.fullname
            u.organization.responsible_name = eu.fullname
          end
          hasChanges = true
        end
        if(!eu.organization && u.organization?)
          u.organization.destroy
          u.organization=nil
          hasChanges = true
        end
        u.save! if(hasChanges)
      else
        u = User.new(
                    username: eu.fullname,
                    email: eu.email,
                    confirmed_at: DateTime.current,
                    password: Devise.friendly_token[0, 20],
                    origin_participacion: true,
                    participacion_id: eu.participacion_id,
                    terms_of_service: "1"
                )
        # Podria ser una asociacion de vecinos en cuyo caso le damos de alta como tal.
        if(eu.organization)
          u.organization = toOrganization(eu)
        end

        if(eu.validated)
            u.verified_at = DateTime.current
        end

        # Podemos no tener email de los usuarios que provienen del sistema externo,
        # por ejemplo usuarios
        u.skip_email_validation = true

        u.save!

      end
      # Autenticaríamos a este usuario
      success! u
    else
      # Ha fallado el proceso de autenticación con este usuario, no informamos de nada... dejamos
      # que continue el proceso normal de autenticacion
      fail()
    end
  end

  private

   def toOrganization(eu)
     return Organization.new(
        name: eu.fullname,
        verified_at: DateTime.current,
        responsible_name: eu.fullname
     )
   end

  def token
      t = params['authToken']
      if(t)
        my_object = JSON.parse(Base64.urlsafe_decode64(t))
        # Verificamos el digest
        if(my_object["uuid"] && my_object["mac"])
           hexdigest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),Rails.application.secrets.secret_key_base,my_object["uuid"])
           my_object["uuid"] if(my_object["mac"] == hexdigest)
        end
      end
    end
end
