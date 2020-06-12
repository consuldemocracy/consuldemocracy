class ParticipacionTokenStrategy < Warden::Strategies::Base
  def valid?
    token.present?
  end

  def authenticate!
    puts "Hola"
    # El usuario externo que tenemos registrado...
    eu = ExternalUser.get(token)
    # Deberíamos localizar el usuario por email y si no existe.. es cuando lo crearíamos
    puts eu
    if(eu)
      u = User.find_by(email: eu.email)
      if(u)
        hasChanges = false
        if(eu.fullname != u.username)
          u.username = eu.fullname
          hasChanges = true
        end
        if(eu.validated && !u.level_three_verified?)
          u.verified_at = DateTime.current
          hasChanges = true
        end
        u.save! if(hasChanges)
      else
        u = User.new(
                    username: eu.fullname,
                    email: eu.email,
                    confirmed_at: DateTime.current,
                    password: Devise.friendly_token[0, 20],
                    terms_of_service: "1"
                )

        if(eu.validated)
            u.verified_at = DateTime.current
        end

        u.save!
      end
      # Autenticaríamos a este usuario
      success!(u)
    else
      # Ha fallado el proceso de autenticación con este usuario, no informamos de nada... dejamos
      # que continue el proceso normal de autenticacion
      fail()
    end
  end

  private
    def token
      params['authToken']
    end
end
