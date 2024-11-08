# Configuración del servidor de correo

Este es un ejemplo de cómo integrar un servicio de correo con Consul Democracy.

## Obtener una cuenta de tu proveedor de correos de confianza

Para poder configurar el correo en Consul Democracy necesitaremos:

* El _smtp_address_, que es la dirección del servidor SMTP de tu proveedor de correos (por ejemplo, smtp.tudominio.com).
* El _domain_, que es el nombre de dominio de tu aplicación.
* El _user_name_ y _password_, que son las credenciales que tu proveedor de correos te proporciona para autenticarte en el servidor SMTP.

## Configuración del correo en Consul Democracy

1. Ve al archivo `config/secrets.yml`.
2. Modifica las siguientes líneas en la sección de `staging`, `preproduction` or `production`, dependiendo de tu configuración:

```yml
  mailer_delivery_method: :smtp
  smtp_settings:
     :address: "<smtp address>"
     :port: 587
     :domain: "<domain>"
     :user_name: "<user_name>"
     :password: "<password>"
     :authentication: "plain"
     :enable_starttls_auto: true
```

3. Rellena `<smtp address>`, `<domain>`, `<user_name>` y `<password>` con tu información.
4. Guarda el fichero y reinicia tu aplicación Consul Democracy.
