module Marketo
  class Lead
    def initialize(email, idnum = nil)
      @email = email
      @idnum = idnum
      @attributes = {}
      set_attribute('Email', @email)
    end

    def self.from_hash(savon_hash)
      lead_record = Lead.new(savon_hash[:email], savon_hash[:id].to_i)
      savon_hash[:lead_attribute_list][:attribute].each do |attribute|
        lead_record.set_attribute(attribute[:attr_name], attribute[:attr_value])
      end
      lead_record
    end

    def idnum
      @idnum
    end

    def email
      @email
    end

    def attributes
      @attributes
    end

    def set_attribute(name, value)
      @attributes[name] = value
    end

    def get_attribute(name)
      @attributes[name]
    end
  end
end