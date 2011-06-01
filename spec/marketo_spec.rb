require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "marketo"
require "yaml"
require "erb"

describe Marketo do
  describe Marketo::Client do
    IDNUM = 89381
    EMAIL = "john@backupify.com"
    COOKIE = "id:572-ZRG-001&token:_mch-localhost-1306412206125-92040"
    USER = {:email => "john@backupify.com", :first_name => "john", :last_name => "kelly"}

    before(:all) do
      @config_options = {}
      File.open("#{Rails.root}/config/marketo.yml") do |f|
        @config_options = YAML::load(ERB.new(f.read).result)
      end

      @client = Marketo::Client.new_marketo_client(@config_options['access_key'], @config_options['secret_key'])
    end

    describe 'initialization' do
      it 'should open the initialization file' do
        File.exists?("#{Rails.root}/config/marketo.yml").should == true

        @config_options.should have(2).items
        @config_options.should include("access_key")
        @config_options.should include("secret_key")
        #@config_options['access_key'].should == "bigcorp1_461839624B16E06BA2D663"
        #@config_options['secret_key'].should == "899756834129871744AAEE88DDCC77CDEEDEC1AAAD66"
      end
    end

    describe 'Exception handling' do
      before do
        VCR.insert_cassette "fault", :record => :new_episodes
      end

      it "should return error if no id is provided" do
        lambda { @client.get_lead_by_id(nil) }.should raise_exception(Exception, "ID must be provided")
      end

      it "should return error if no email is provided" do
        lambda { @client.get_lead_by_email(nil) }.should raise_exception(Exception, "Email must be provided")
      end

      it "should return SOAP fault if email is invalid" do
        lambda { @client.get_lead_by_email("JUNK") }.should raise_exception(Savon::SOAP::Fault)
      end

      it "should return error if no email is provided on sync lead" do
        lambda { @client.sync_lead(nil, "", {}) }.should raise_exception(Exception, "Email must be provided")
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'Lead' do
      before do
        VCR.insert_cassette "lead", :record => :new_episodes
      end

      it "should get lead by id" do
        lead_record = Marketo::Lead.new(nil, IDNUM)
        retVal = @client.get_lead_by_id(IDNUM)
        retVal.should be_a_kind_of(Marketo::Lead)
        retVal.idnum.should == IDNUM
      end

      it "should get lead by email" do
        lead_record = Marketo::Lead.new(EMAIL)
        retVal = @client.get_lead_by_email(EMAIL)
        retVal.should be_a_kind_of(Marketo::Lead)
        retVal.email.should == EMAIL
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'Sync' do
      before do
        VCR.insert_cassette "sync", :record => :new_episodes
      end

      it "should sync lead with Marketo" do
        client = Marketo::Client.new_marketo_client(@config_options['access_key'], @config_options['secret_key'])
        retVal = client.sync_lead(USER[:email], COOKIE, {"FirstName"=>USER[:first_name],
                                                       "LastName"=>USER[:last_name],
                                                       "Company"=>"Backupify"})
        retVal.should be_a_kind_of(Marketo::Lead)
      end

      after do
        VCR.eject_cassette
      end
    end

    describe 'List' do
      before do
        VCR.insert_cassette "list", :record => :new_episodes
      end

      it "should add lead to marketo list" do
        client = Marketo::Client.new_marketo_client(@config_options['access_key'], @config_options['secret_key'])
        retVal = client.add_lead_to_list(IDNUM, "Inbound Signups").should == true
      end

      after do
        VCR.eject_cassette
      end
    end
  end
end