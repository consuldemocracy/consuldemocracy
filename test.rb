def build_request_body(date, nonce, token, document_number, municipality_id)
  encoded_document_number = Base64.encode64(document_number).delete("\n")

  sml_message = Rack::Utils.escape_html(
    "<E>\n\t<OPE>\n\t\t<APL>PAD</APL>\n\t\t<TOBJ>HAB</TOBJ>\n\t\t<CMD>ISHABITANTE</CMD>"\
    "\n\t\t<VER>2.0</VER>\n\t</OPE>\n\t<SEC>\n\t\t<CLI>ACCEDE</CLI>\n\t\t"\
    "<ORG>#{municipality_id}</ORG>\n\t\t"\
    "<ENT>#{municipality_id}</ENT>"\
    "\n\t\t<USU>" + census_user + "</USU>\n\t\t<PWD>" + encoded_census_password + "</PWD>\n\t\t<FECHA>" + date + "</FECHA>\n\t\t<NONCE>" + nonce + "</NONCE>"\
    "\n\t\t<TOKEN>" + token + "</TOKEN>\n\t</SEC>\n\t<PAR>\n\t\t<nia></nia>\n\t\t<codigoTipoDocumento>1</codigoTipoDocumento>"\
    "\n\t\t<documento>" + encoded_document_number + "</documento>\n\t\t<mostrarFechaNac>-1</mostrarFechaNac>\n\t</PAR>\n</E>"
  )

  body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
  body += "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
  body += "<SOAP-ENV:Body>"
  body += "<m:servicio xmlns:m=\"" + census_host + "\"><sml>#{sml_message}</sml></m:servicio>"
  body += "</SOAP-ENV:Body></SOAP-ENV:Envelope>"

  body
end

def census_host
  Rails.application.secrets.padron_host
end

def census_user
  Rails.application.secrets.padron_user
end

def current_date
  Time.now.strftime("%Y%m%d%H%M%S")
end

def encoded_token(nonce, date)
  Digest::SHA512.base64digest(nonce + date + Rails.application.secrets.padron_public_key)
end

def encoded_census_password
  Digest::SHA1.base64digest(Rails.application.secrets.padron_password)
end

def log(message)
  Rails.logger.info("[Census WS] #{message}") unless Rails.env.production?
end



document_number = "12732329N"
nonce = 18.times.map { rand(10) }.join
postal_code = "47100"
entities = CENSUS_DICTIONARY[postal_code]
entity_code = entities.first
census_geozone_external_code = GEOZONES_DICTIONARY[entity_code]



date = current_date
request_body = build_request_body(date, nonce, encoded_token(nonce, date), document_number, entity_code)
puts census_geozone_external_code
puts request_body
# RestClient.post(
#   census_host,
#   request_body,
#   { content_type: "text/xml; charset=utf-8", SOAPAction: census_host }
# )

