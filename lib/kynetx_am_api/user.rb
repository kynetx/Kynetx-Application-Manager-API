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
    # OAuth Acces sSecret
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
    # :request_token
    # :request_secret
    # :oauth_verifier
    # :access_token
    # :access_secret
    # :username
    # :userid
    # :name
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


    def api
      @api ||= KynetxAmApi::DirectApi.new({:access_token => @access_token, :access_secret => @access_secret})
      return @api
    end

    #
    # Read applications list 
    #
    # :offset => Start in list (not implemented)
    # :size => Number of application to list (not implemented)
    #
    # Returns a has with two keys
    # "apps" => Array Off Hashes with :appid , :role, :name, :created
    # "valid" => true
    #
    def applications(options = {})
      @applications = api.get_applist if !@applications
      @applications
    end

    #
    # :application_id => application_id
    # :version => Version of application to obtain
    #
    def find_application(options = {})
      options[:version] ||= "development"
      raise "Expecting :application_id" unless options[:application_id]
      
      puts "Creating a new Application object."
      if @current_application && @current_application.application_id != options[:application_id]
        @current_application = KynetxAmApi::Application.new(self, options[:application_id], options[:version])
      else
        @current_application ||= KynetxAmApi::Application.new(self, options[:application_id], options[:version])
      end
      # rst  = api.get_app_source(options[:application_id],options[:version], :krl);
      # app.source = rst;
      return @current_application
    end


    def create_application(name, description="")
      appid = api.get_appcreate["appid"]
      @current_application = KynetxAmApi::Application.new(self, appid).create_initial_app(name, description)
      
      return @current_application
    end
    
    def duplicate_application(application_id)
      old_app = KynetxAmApi::Application.new(self, application_id)
      new_app = create_application(old_app.name, "")
      new_app.krl = old_app.krl
      return new_app
    end
    
    def owns_current?
      puts "OWNER / CURRENT_APP: #{@current_application.name}"
      return false unless @current_application
      puts "ME: #{self.userid.to_i}  OWNER: #{@current_application.owner["kynetxuserid"].to_i}"
      return @current_application.owner["kynetxuserid"].to_i == self.userid.to_i
    end


  end
end