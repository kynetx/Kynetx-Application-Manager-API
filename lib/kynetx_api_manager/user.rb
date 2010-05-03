module KynetxApiManager
  class User
    attr_accessor :request_token
    attr_accessor :request_secret
    attr_accessor :oauth_verifier
    attr_accessor :access_token
    attr_accessor :access_secret
    attr_accessor :username
    attr_accessor :userid
    attr_accessor :name
    attr_reader :current_application

    # attr :api
    # attr :applications

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
      @api ||= KynetxApiManager::KynetxApi.new({:access_token => @access_token, :access_secret => @access_secret})
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
        @current_application = Application.new(self, options[:application_id], options[:version])
      else
        @current_application ||= Application.new(self, options[:application_id], options[:version])
      end
      # rst  = api.get_app_source(options[:application_id],options[:version], :krl);
      # app.source = rst;
      return @current_application
    end


    def create_application(name, description="")
      appid = api.get_appcreate["appid"]
      @current_application = Application.new(self, appid).create_initial_app(name, description)
      
      return @current_application
    end
    
    def duplicate_application(application_id)
      old_app = Application.new(self, application_id)
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