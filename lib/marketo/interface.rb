module Marketo
  require "openssl"

  class Interface
    attr_accessor :client

    def initialize(client, header)
      @client = client
      @header = header
    end

    def send_request(namespace, body)
      response = @client.request(namespace) do |soap|
        soap.use_ssl = true
        soap.ssl_version = "SSLv3"
        soap.namespaces["xmlns:ns1"] = "http://www.marketo.com/mktows/"
        soap.body = body
        soap.header["ns1:AuthenticationHeader"] = @header.to_hash
      end
    end

    public

    def get_lead_by_id(id)
      raise Exception, "ID must be provided" if id.nil?

      lead = ParamsGetLead.new("IDNUM", id)
      response = send_request("ns1:paramsGetLead", {:lead_key => lead.to_hash})
      return Lead.from_hash(response[:success_get_lead][:result][:lead_record_list][:lead_record])
    end

    def get_lead_by_email(email)
      raise Exception, "Email must be provided" if email.nil?

      lead = ParamsGetLead.new("EMAIL", email)
      response = send_request("ns1:paramsGetLead", {:lead_key => lead.to_hash})
      return Lead.from_hash(response[:success_get_lead][:result][:lead_record_list][:lead_record])
    end

    def sync_lead(email, cookie, user_args = {})
      raise Exception, "Email must be provided" if email.nil?

      if(cookie.nil? || (cookie.include?("token:") == false))
        @cookie = ""
      else
        @cookie = cookie.slice!(cookie.index("token:")..-1)
      end

      lead = ParamsSyncLead.new(email, user_args)
      response = send_request("ns1:paramsSyncLead", {:return_lead => true, :lead_record => lead.to_hash, :marketo_cookie => @cookie})
      return Lead.from_hash(response[:success_sync_lead][:result][:lead_record])
    end

    def add_lead_to_list(idnum, list_name)
      list = ParamsListOperation.new(list_name, idnum)
      response = send_request("ns1:paramsListOperation", {:list_operation => "ADDTOLIST", :list_key => list.list_key_hash, :list_member_list => list.list_member_hash, :strict => true})
      return response[:success_list_operation][:result][:success]
    end
  end

  # {https://na-l.marketo.com/soap/mktows/1_6}GetLead
  #
  #   success - SOAP::SOAPBoolean
  class ParamsGetLead
    attr_accessor :key_type
    attr_accessor :key_value

    def initialize(key_type = "EMAIL", key_value = nil)
      @key_type = key_type
      @key_value = key_value
    end

    def to_hash
      {
        :key_type => @key_type,
        :key_value => @key_value
      }
    end
  end

  # {https://na-l.marketo.com/soap/mktows/1_6}SyncLead
  #
  #   success - SOAP::SOAPBoolean
  class ParamsSyncLead
    attr_accessor :id
    attr_accessor :email
    attr_accessor :cookie
    attr_accessor :attributes

    def initialize(email, user_args = {})
      @email = email

      @attributes = []
      user_args.each_pair do |name, val|
        @attributes << to_attribute_hash(name, val)
      end
    end

    def to_hash
      {
        "Email" => @email,
        :lead_attribute_list => {
          :attribute => @attributes
        }
      }
    end

    def to_attribute_hash(key, value, type = "string")
      { "attrName" => key, "attrValue" => value, "attrType" => type }
    end
  end

  # {https://na-l.marketo.com/soap/mktows/1_6}ListOperation
  #
  #   success - SOAP::SOAPBoolean
  class ParamsListOperation
    attr_accessor :list_name
    attr_accessor :key_value

    def initialize(list_name, key_value)
      @list_name = list_name
      @key_value = key_value
    end

    def list_key_hash
      {
        :key_type => "MKTOLISTNAME", :key_value => @list_name
      }
    end

    def list_member_hash
      {
        :lead_key => {:key_type => "IDNUM", :key_value => @key_value}
      }
    end
  end

  class AuthenticationHeader
    DIGEST = OpenSSL::Digest::Digest.new('sha1')

    def initialize(access_key, secret_key, time = DateTime.now)
      @access_key = access_key
      @secret_key = secret_key
      @time = time
    end

    def to_hash
      {
        "mktowsUserId"     => get_mktows_user_id,
        "requestSignature" => get_request_signature,
        "requestTimestamp" => get_request_timestamp
      }
    end

    def get_mktows_user_id
      @access_key
    end

    def get_request_signature
      calculate_signature
    end

    def get_request_timestamp
      @time.to_s
    end

    private
    def calculate_signature
      request_timestamp = get_request_timestamp
      string_to_encrypt = request_timestamp + @access_key
      OpenSSL::HMAC.hexdigest(DIGEST, @secret_key, string_to_encrypt)
    end
  end
end