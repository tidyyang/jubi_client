require "jubi_client/version"

require 'rest-client'
require 'openssl'
require 'addressable/uri'

module JubiClient

  class << self
    attr_accessor :configuration
  end

  def self.setup
    @configuration ||= Configuration.new
    yield( configuration )
  end

  class Configuration
    attr_accessor :key, :secret

    def intialize
      @key    = ''
      @secret = ''
    end
  end

  def self.ticker code
    get 'ticker', coin: code
  end

  def self.depth code
    get 'depth', coin: code
  end

  def self.orders code
    get 'orders', coin: code
  end

  def self.allticker
    get 'allticker'
  end

  def self.balances
    post 'balance'
  end

  protected

  def self.resource
    @@resouce ||= RestClient::Resource.new( 'https://www.jubi.com/api/v1/' )
  end

  def self.get( command, params = {} )
    resource[ command ].get params: params
  end

  def self.post( command, params = {} )
    params[:nonce]   = Time.now.to_i * 1000
    params[:key] = configuration.key
    params[:signature] = create_sign( params )
    resource[ command ].post params
  end

  def self.create_sign( data )
    md5 = Digest::MD5.new
    md5.update configuration.secret
    sc = md5.hexdigest

    encoded_data = Addressable::URI.form_encode( data )
    OpenSSL::HMAC.hexdigest( 'sha256', sc, encoded_data )
  end

end
