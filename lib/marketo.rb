require "savon"
require "savon_model"
require "openssl/digest"

require "marketo/client"
require "marketo/interface"
require "marketo/lead"

module Marketo
  class << self
    attr_accessor :access_key, :secret_key
  end

  def self.configure
    yield self
  end
end