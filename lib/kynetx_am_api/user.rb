module KynetxAmApi
  #
  # Simple wrapper to allow access to the OAuth user information.   This also hold some basic user data like
  # username, name and user id.
  #
  class User
    # OAuth Request Token
    attr_accessor :request_token
    # OAuth Secret Token
    attr_accessor :request_secret
    # OAuth Verifieer
    attr_accessor :oauth_verifier
    # OAuth Access Token
    attr_accessor :access_token
    # OAuth Access Secret
    attr_accessor :access_secret
    # Kynetx User name
    attr_accessor :username
    # Kynetx User ID
    attr_accessor :userid
    # Full name of user
    attr_accessor :name
    # Current Application context.
    attr_reader :current_application


    #
    # Accepts a hash that has the following entries.
    # - :request_token
    # - :request_secret
    # - :oauth_verifier
    # - :access_token
    # - :access_secret
    # - :username
    # - :userid
    # - :name
    #

    def initialize(attributes)
      @request_token = attributes[:request_token]
      @request_secret = attributes[:request_secret]
      @oauth_verifier = attributes[:oauth_verifier]
      @access_token = attributes[:access_token]
      @access_secret = attributes[:access_secret]
      @username = attributes[:username]
      @userid = attributes[:userid]
      @name = attributes[:name]
      @current_applicaion = nil
    end

    #
    # Returns the direct api to the Kynetx Application Manager.
    #
    def api
      @api ||= KynetxAmApi::DirectApi.new({:access_token => @access_token, :access_secret => @access_secret})
      return @api
    end

    #
    # Read applications list 
    #
    # - :offset => Start in list (not implemented)
    # - :size => Number of application to list (not implemented)
    #
    # Returns a Hash with two keys
    # - "apps" => Array Off Hashes with :appid , :role, :name, :created
    # - "valid" => true
    #
    def applications(options = {})
      @applications = api.get_applist if !@applications
      @applications
    end

    #
    # - :application_id => application_id
    #
    def find_application(options = {})
      raise "Expecting :application_id" unless options[:application_id]
      
      if @current_application && @current_application.application_id != options[:application_id]
        @current_application = KynetxAmApi::Application.new(self, options[:application_id])
      else
        @current_application ||= KynetxAmApi::Application.new(self, options[:application_id])
      end
      return @current_application
    end


    def create_application(name, description="")
      response = api.get_appcreate

      raise "Error from API: #{response["error"]}" if not response["valid"]

      appid = response["appid"]
      @current_application = KynetxAmApi::Application.new(self, appid).create_initial_app(name, description)
      
      return @current_application
    end
    
    def duplicate_application(application_id)
      old_app = KynetxAmApi::Application.new(self, application_id)
      new_app = create_application(old_app.name || "", "")
      new_app.krl = old_app.krl
      return new_app
    end
    
    def owns_current?
      return false unless @current_application
      return false unless @current_application.owner
      return @current_application.owner["kynetxuserid"].to_i == self.userid.to_i
    end
    
    def to_h
      return {
        :access_secret => @access_secret,
        :access_token => @access_token,
        :request_token => @request_token,
        :request_secret => @request_secret,
        :oauth_verifier => @oauth_verifier,
        :name => @name,
        :userid => @userid,
        :username => @username
      }
    end

    def kpis(rulesets=[], range=nil)
      conditions = rulesets.empty? ? nil : []
      rulesets.each do |ruleset|
        conditions.push << {:field => "ruleset", :value => ruleset}
      end
      return api.get_stats_query("rse,brse,rules,rules_fired,actions,callbacks", 'ruleset,day', conditions, range)
    end

    def stats_interface
      return api.get_stats_interface
    end


  end
end
