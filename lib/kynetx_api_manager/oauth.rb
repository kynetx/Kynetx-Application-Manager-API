module KynetxApiManager
  require 'oauth'
  require 'json'
  require 'pp'

  class Oauth

    cattr_accessor :accounts_server_url
    cattr_accessor :api_server_url
    cattr_accessor :consumer_key
    cattr_accessor :consumer_secret

    attr_accessor :request_token
    attr_accessor :account_consumer
    attr_accessor :api_consumer
    attr_accessor :user
    attr_accessor :access_token


    def initialize(user=nil)
      @user = User.new(user)
      if @user.oauth_verifier
        access_tokens
      end
    end

    def get_access_token
      return @access_token if @access_token
      return @access_token = OAuth::AccessToken.new(get_api_consumer, @user.access_token, @user.access_secret)
    end

    def get_request_token
      return @request_token if @request_token
      return @request_token = get_account_consumer.get_request_token
    end


    private

   
    def access_tokens
      access_request_token = OAuth::RequestToken.new(get_account_consumer, @user.request_token, @user.request_secret)
      access_token_data = access_request_token.get_access_token :oauth_verifier => @user.oauth_verifier
      @user.access_token = access_token_data.token
      @user.access_secret = access_token_data.secret

    end


    private

    def get_account_consumer
#      puts Oauth.consumer_key
#      puts Oauth.consumer_secret
#      puts Oauth.accounts_server_url

      return @account_consumer if @account_consumer

      # TODO: Accounts url must come form settings.

      return @account_consumer = OAuth::Consumer.new(Oauth.consumer_key, Oauth.consumer_secret, {
              :site               => Oauth.accounts_server_url,
              :scheme             => :header,
              :method             => :get,
              :request_token_path => "/oauth/request_token",
              :access_token_path  => "/oauth/access_token",
              :authorize_path     => "/oauth/authorize",
              :oauth_version      => "1.0a"
      })


    end


    def get_api_consumer
      return @api_consumer if @api_consumer

      # TODO: Accounts url must come form settings.

#      puts Oauth.consumer_key
#      puts Oauth.consumer_secret
#      puts Oauth.api_server_url


      return @api_consumer = OAuth::Consumer.new(Oauth.consumer_key, Oauth.consumer_secret, {
              :site               => Oauth.api_server_url,
              :scheme             => :header,
              :method             => :get,
              :request_token_path => "/oauth/request_token",
              :access_token_path  => "/oauth/access_token",
              :authorize_path     => "/oauth/authorize",
              :oauth_version      => "1.0a"
      })


    end

  end
end