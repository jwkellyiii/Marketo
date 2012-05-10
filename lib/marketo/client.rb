module Marketo
  class Client
    include Savon::Model

    actions :describe_m_object, :get_campaigns_for_source, :get_lead, :get_lead_activity, :get_lead_changes, :get_multiple_leads, :list_m_objects, :list_operation, :request_campaign, :sync_lead, :sync_multiple_leads

    attr_accessor :client
    attr_accessor :header
    attr_accessor :cookie

    def self.new_marketo_client(access_key, secret_key)
      @client = Savon::Client.new do
        http = HTTPI::Request.new({:ssl_version=>"SSLv3"})
        http.headers["Pragma"] = "no-cache"
        wsdl.endpoint = "https://na-l.marketo.com/soap/mktows/1_6"
        wsdl.document = "http://app.marketo.com/soap/mktows/1_4?WSDL"
      end

      @header = AuthenticationHeader.new(access_key, secret_key)

      Interface.new(@client, @header)
    end
  end
end