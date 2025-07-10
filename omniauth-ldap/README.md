# OmniAuth LDAP

== LDAP

Use the LDAP strategy as a middleware in your application:

    use OmniAuth::Strategies::LDAP, 
        :title => "My LDAP", 
        :host => '10.101.10.1',
        :port => 389,
        :method => :plain,
        :base => 'dc=intridea, dc=com',
        :uid => 'sAMAccountName',
        :name_proc => Proc.new {|name| name.gsub(/@.*$/,'')},
        :bind_dn => 'default_bind_dn',
        # Or, alternatively:
        #:filter => '(&(uid=%{username})(memberOf=cn=myapp-users,ou=groups,dc=example,dc=com))'
        :name_proc => Proc.new {|name| name.gsub(/@.*$/,'')}
        :bind_dn => 'default_bind_dn'
        :password => 'password'

All of the listed options are required, with the exception of :title, :name_proc, :bind_dn, and :password.
Allowed values of :method are: :plain, :ssl, :tls.

:bind_dn and :password is the default credentials to perform user lookup.
  most LDAP servers require that you supply a complete DN as a binding-credential, along with an authenticator
  such as a password. But for many applications, you often don’t have a full DN to identify the user. 
  You usually get a simple identifier like a username or an email address, along with a password. 
  Since many LDAP servers don't allow anonymous access, search function will require a bound connection, 
  :bind_dn and :password will be required for searching on the username or email to retrieve the DN attribute 
  for the user. If the LDAP server allows anonymous access, you don't need to provide these two parameters.

:uid is the LDAP attribute name for the user name in the login form. 
  typically AD would be 'sAMAccountName' or 'UserPrincipalName', while OpenLDAP is 'uid'.

:filter is the LDAP filter used to search the user entry. It can be used in place of :uid for more flexibility.
  `%{username}` will be replaced by the user name processed by :name_proc.

:name_proc allows you to match the user name entered with the format of the :uid attributes. 
  For example, value of 'sAMAccountName' in AD contains only the windows user name. If your user prefers using 
  email to login, a name_proc as above will trim the email string down to just the windows login name. 
  In summary, use :name_proc to fill the gap between the submitted username and LDAP uid attribute value.
 
:try_sasl and :sasl_mechanisms are optional. :try_sasl [true | false], :sasl_mechanisms ['DIGEST-MD5' | 'GSS-SPNEGO']
  Use them to initialize a SASL connection to server. If you are not familiar with these authentication methods, 
  please just avoid them.

Direct users to '/auth/ldap' to have them authenticated via your company's LDAP server.


## License

Copyright (C) 2011 by Ping Yu and Intridea, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
