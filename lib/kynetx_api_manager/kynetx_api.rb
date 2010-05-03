module KynetxApiManager
  require 'oauth'
  require 'json'
  require 'pp'
  require 'net/http/post/multipart'

  class KynetxApi

    attr_accessor :oauth

    #
    # Create a new session to the KynetxApi Manager.
    #
    # request_token
    # request_secret
    #     :request_token
    #     :request_secret
    #     :oauth_verifier
    #     :access_token
    #     :access_secret
    #
    def initialize(tokens_and_secrets = {})
      @oauth = KynetxApiManager::Oauth.new(tokens_and_secrets)
    end

    #
    def get_request_token
      @oauth.get_request_token
    end

    #
    # Provides the url to direct user to if the application has not been authorized. 
    #
    def get_authorize_url
      return get_request_token.authorize_url
    end


    #
    # API Call From Here Down.
    #

    #
    #
    def get_applist
      return get_response("applist", :json)
    end

    def get_appcreate
      return get_response("appcreate", :json)
    end

    def post_app_delete(application_id)
      return post_response("app/#{application_id}/delete", {})
    end

    def post_remove_user(application_id, user_id)
      return post_response("app/#{application_id}/removeuser", {"userid" => user_id})
    end

    def post_app_inviteuser(application_id, application_name, email, message)
      return post_response("app/#{application_id}/inviteuser", {"email" => email, "message" => message, "appname" => application_name.to_s})
    end

    def post_app_invitecancel(application_id, invite_id)
      return post_response("app/#{application_id}/invitecancel",{"inviteid" => invite_id})
    end

    def post_app_transferownershiprequest(application_id,application_name,user_id,message)
      return post_response("app/#{application_id}/ownershiptransferrequest", {"userid" => user_id, "message" => message, "appname" => application_name})
    end

    def post_app_ownershiptransfercancel(application_id,transfer_id)
      return post_response("app/#{application_id}/ownershiptransfercancel", {"ownershiptransferrequestid" => transfer_id})
    end

    #
    # type is one of ff = firefox, ie = internet explorer, cr = google chrome
    #
    def post_app_generate(application_id, type, opts={})
            # 
            # default_options = {
            #   "name" => "",
            #   "author" => "",
            #   "description" => "",
            #   "guid" => "",
            #   "datasets" => "",
            #   "env" => "prod",
            #   "image_url" => "http://appresource.s3.amazonaws.com/apiappimages/missing_icard.jpg",
            #   "runtime" => ""
            # }
            # options = default_options.merge(opts)
      return post_response("app/#{application_id}/generate/#{type}", opts,:json)
    end


    def get_app_source(application_id, version, format = :krl)
      data =  get_response("app/#{application_id}/source/#{version}/#{format}", format)
      return data
    end

    def get_app_info(application_id)
      return get_response("app/#{application_id}/info", :json)
    end
    
    def get_app_details(application_id)
      return get_response("app/#{application_id}/details", :json)
    end


    def post_app_source(application_id, source, type = "krl")
      data = ""
      if type == "krl"
        data = {:krl => source.to_s}
      else
        data = {:json => source.to_json}
      end
      return post_response("app/#{application_id}/source", data)
    end


    def post_app_setproductversion(application_id, version)
      return post_response("app/#{application_id}/setproductionversion", {"version" => version})
    end
    
    def post_app_setversionnote(application_id, version, note)
      return post_response("app/#{application_id}/setversionnote", {"version" => version, "note" => note}, :json)
    end
    
    def post_app_updateappimage(application_id, filename, content_type, image_data)
      # headers = {'Content-type'=>'multipart/form-data'}
      # puts "IMAGE INFO: #{image.class}"
      # return multipart_post_response("app/#{application_id}/updateappimage", {:image => image})
      response = ""
      
      url = URI.parse('https://accounts.kynetx.com/api/0.1/updateAppInfo')
      
      StringIO.open(image_data) do |i|
        req = Net::HTTP::Post::Multipart.new url.path,
          "image" => UploadIO.new(i, content_type, filename),
          "appid" => application_id
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        response = http.start { |h| h.request(req) }        
      end
      
      return response
    end

    def ping
      return get_response("ping")
    end

    def get_user_info
      user = @oauth.user
      if user.username.blank?
        user_info = get_response("userinfo", :json)
        user.username = user_info["username"]
        user.userid = user_info["userid"]
        user.name = user_info["name"]
      end
      return user
    end

    private

    def get_response(api_method, format = nil)
      if format == :json
        headers = {'Accept'=>'application/json'}
      end
      api_call = "/0.1/#{api_method}"
      puts "---------GET---------------"
      puts api_call
      puts "___________________________"
      response = @oauth.get_access_token.get(api_call, headers).body
      puts response.inspect if RAILS_ENV == 'development'
      puts "___________________________"
      begin
        response = JSON.parse(response) if format == :json
      rescue
        puts $!
        raise "Unexpected response from the api: (#{api_method}) :: #{response}"
      end
      return response
    end

    # Probably a better way to do this.  Make it a little more DRY
    def post_response(api_method, data, format=nil, additional_headers=nil)
      if format == :json
        headers = {'Accept'=>'application/json'}
      end
      if additional_headers
        headers.merge!(additional_headers)
      end
      api_call = "/0.1/#{api_method}"
      puts "---------POST--------------"
      puts api_call
      puts data.inspect if RAILS_ENV == 'development'
      puts "___________________________"
      response = @oauth.get_access_token.post(api_call, data, headers).body
      puts response.inspect if RAILS_ENV == 'development'
      puts "---------------------------"
      begin
        response = JSON.parse(response) if format == :json
      rescue
        puts $!
        raise "Unexpected response from the api: (#{api_method}) :: #{response}"
      end
      return response
    end
    
    # CRLF = "\r\n"
    #    # Encodes the request as multipart
    #    def add_multipart_data(req,params)
    #      boundary = Time.now.to_i.to_s(16)
    #      req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
    #      body = ""
    #      params.each do |key,value|
    #        esc_key = CGI.escape(key.to_s)
    #        body << "--#{boundary}#{CRLF}"
    #        if value.respond_to?(:read)
    #          puts "GOT IO"
    #          #body << "Content-Disposition: form-data; name=\"#{esc_key}\"; filename=\"#{File.basename(value.path)}\"#{CRLF}"
    #          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF}"
    #          body << "Content-Type: image/jpg#{CRLF*2}"
    #          body << value.read
    #        else
    #          puts "GOT NO IO"
    #          body << "Content-Disposition: form-data; name=\"#{esc_key}\"#{CRLF*2}#{value}"
    #        end
    #        body << CRLF
    #      end
    #      body << "--#{boundary}--#{CRLF*2}"
    #      req.body = body
    #      req["Content-Length"] = req.body.size
    #    end
    # 
    #    # Uses the OAuth gem to add the signed Authorization header
    #    def add_oauth(req)
    #      @oauth.api_consumer.sign!(req, @oauth.get_access_token)
    #    end
    # 
    #    def multipart_post_response(api_method, data)
    #      response = ""
    #      url = URI.parse(@oauth.api_server_url + "/0.1/" + api_method)
    #      puts "URL: #{url.inspect}"
    #      Net::HTTP.new(url.host, url.port).start do |http|
    #        req = Net::HTTP::Post.new(url.request_uri)
    #        add_multipart_data(req, data)
    #        add_oauth(req)
    #        
    #        puts "REQUEST (#{req["Content-Length"]}):"
    #        puts req.body
    #        puts "-"*20
    #        
    #        res = http.request(req)
    #        response =  res.body
    #        puts "RESPONSE"
    #        puts res.body
    #      end
    #      return response
    #    end
    
    
  end
end