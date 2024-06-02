module Http2k
  module Helper
    require 'openssl'
    require 'resolv'
    require 'base64'

    def create_cert(cn)
      # Return a hash with private key and certificate in x509 format
      key = OpenSSL::PKey::RSA.new 4096
      name = OpenSSL::X509::Name.parse "CN=#{cn}/DC=redborder"
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 0
      cert.not_before = Time.now
      cert.not_after = Time.now + (3600 * 24 * 365 * 10)
      cert.public_key = key.public_key
      cert.subject = name
      cert.issuer = name
      if cn.start_with?('s3.')
        extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert
        cert.add_extension extension_factory.create_extension('subjectAltName', "DNS:redborder.#{cn}", false)
        cert.add_extension extension_factory.create_extension('subjectAltName', "DNS:rbookshelf.#{cn}", false)
        cert.add_extension extension_factory.create_extension('subjectAltName', "DNS:#{cn}", false)
      end
      cert.sign key, OpenSSL::Digest.new('SHA1')
      { key: key, crt: cert }
    end

    def create_json_cert(app, cdomain)
      ret_json = { 'id' => app }
      cert_hash = create_cert("#{app}.#{cdomain}")
      ret_json["#{app}_crt"] = Base64.urlsafe_encode64(cert_hash[:crt].to_pem)
      ret_json["#{app}_key"] = Base64.urlsafe_encode64(cert_hash[:key].to_pem)
      ret_json
    end

    def nginx_certs(app, cdomain)
      ret_json = {}

      # Check if certs exists in a data bag
      begin
        nginx_cert_item = data_bag_item('certs', app)
      rescue
        nginx_cert_item = {}
      end

      if nginx_cert_item.empty?
        unless File.exist?("/var/chef/data/data_bag/certs/#{app}.json")
          # Create S3 certificate
          ret_json = create_json_cert(app, cdomain)
          system('mkdir -p /var/chef/data/data_bag/certs')
          File.write("/var/chef/data/data_bag/certs/#{app}.json", ret_json.to_json)
        end

        # Upload cert to data bag
        if File.exist?('/root/.chef/knife.rb')
          system("knife data bag from file certs /var/chef/data/data_bag/certs/#{app}.json")
        else
          Chef::Log.warn('knife command not available, certs databag wont be uploaded')
        end
      else
        ret_json = nginx_cert_item
      end
      ret_json
    end

    # Function that return role organization_uuid
    #
    def get_organization_uuid
      organizations = []
      Chef::Role.list.each_key do |m_key|
        m = Chef::Role.load m_key

        next unless m.override_attributes['redborder'] && m.override_attributes['redborder']['organization_uuid'] && m.override_attributes['redborder']['sensor_uuid'] && m.override_attributes['redborder']['sensor_uuid'] == m.override_attributes['redborder']['organization_uuid']

        organizations << m
      end

      organizations
    end
  end
end
