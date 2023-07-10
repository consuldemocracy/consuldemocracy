# Configuración del servidor de correo

Este es un ejemplo de cómo integrar un servicio de correo con Consul Democracy.

En este ejemplo usamos [Mailgun](https://www.mailgun.com/).

## Crear una cuenta en Mailgun

![Creando una cuenta en Mailgun](../../img/mailserver/mailgun-create-account.png)

* Puedes omitir el formulario de tarjeta de crédito
* Y activa tu cuenta con el enlace enviado por correo electrónico

## Configuración del dominio

* Ve a la sección "domain": ![Mailgun sección domain](../../img/mailserver/mailgun-domains.png)
* Como todavía no tienes un dominio, debes pinchar en el "sandbox" que ya está creado
* Recuerda las siguientes credenciales: ![Mailgun sandbox](../../img/mailserver/mailgun-sandbox.png)

## Configuración del correo en Consul Democracy

* Ve al archivo `config/secrets.yml`
* Modifica las líneas en el archivo para configurar el servidor de correo:

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

* Rellena `<smtp address>`, `<domain>`, `<user_name>` y `<password>` con tu información.
* Guarda el fichero y reinicia tu aplicación Consul Democracy
