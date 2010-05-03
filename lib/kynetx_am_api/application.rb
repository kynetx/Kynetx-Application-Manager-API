module KynetxAmApi
  class Application

    attr_reader :name
    attr_reader :user
    attr_reader :application_id
    attr_reader :api

    def initialize(user, application_id, version=nil)
      @api = user.api
      @application_id = application_id
      @user = user
      load_base
    end
    
    def to_param
      return @application_id
    end
    
    def create_initial_app(name, description)
      @name = name
      @description = description
      @meta = DEFAULT_META.gsub("<<NAME>>", name).gsub("<<DESCRIPTION>>", description)
      @global = DEFAULT_GLOBAL
      @dispatch = DEFAULT_DISPATCH
      @first_rule = DEFAULT_RULE.gsub("<<NAME>>", "first_rule")
      set_krl(gen_default_krl)
      load_base
      return self
    end  
    
    def delete
      @api.post_app_delete(@application_id)      
    end

    def krl(v=nil)
      @krl ||= @api.get_app_source(@application_id, v ? v : "development", :krl)
    end
    
    def image_url(size="normal")
      # returns the image url of a given size
      load_base unless @images
      if @images.empty?
        defaults = {
          "thumb" => "http://appresource.s3.amazonaws.com/apiappimages/missing_thumb.png",
          "normal" => "http://appresource.s3.amazonaws.com/apiappimages/missing.png",
          "original" => "http://appresource.s3.amazonaws.com/apiappimages/missing.png",
          "icard" => "http://appresource.s3.amazonaws.com/apiappimages/missing_icard.jpg"
        }
        return defaults[size.to_s]
      end
      return @images[size.to_s]
    end
    
    def set_image(filename, content_type, image_data)
      return @api.post_app_updateappimage(@application_id, filename, content_type, image_data)
    end
    
    def krl=(krl)
      set_krl(krl)
    end
       
    def users
      load_base unless @users
      return @users
    end
    
    def remove_user(userid)
      return @api.post_remove_user(@application_id, userid)
    end
    
    def version
      return development_version
    end
    
    def development_version
      load_versions unless @development_version
      return @development_version      
    end

    def production_version
      load_versions unless @production_version
      return @production_version
    end
    
    def production_version=(version)
      @api.post_app_setproductversion(@application_id, version)
      @production_version = version
    end
    
    def versions
      load_versions unless @versions
      return @versions      
    end
    
    def set_version_note(version, note)
      @api.post_app_setversionnote(@application_id, version, note)
    end
    
    def owner
      load_base unless @owner
      return @owner
    end
    
    def transfer_request
      load_base unless @transfer_request
      return @transfer_request
    end
    
    def transfer_owner(user_id, message)
      load_base unless @name
      return @api.post_app_transferownershiprequest(@application_id, @name, user_id, message)
    end
    
    def cancel_transfer(request_id)
      return @api.post_app_ownershiptransfercancel(@application_id, request_id)
    end
    
    def share(email, message)
      load_base unless @name
      return @api.post_app_inviteuser(@application_id, @name, email, message)
    end
    
    def invites
      load_base unless @invites
      return @invites
    end
    
    def cancel_invite(invite_id)
      return @api.post_app_invitecancel(@application_id, invite_id)
    end
    
    def reload
      load_base
      load_versions
    end
    
    #----- Distrubution Methods
    
    def bookmarklet(env="prod", runtime="init.kobj.net/js/shared/kobj-static.js")
      return @api.post_app_generate(@application_id, "bookmarklet", {"env" => env, "runtime" => runtime})["data"]
    end
    
    def infocard(name, datasets, env="prod")
      load_base unless @guid
      options = {
        "extname" => name.gsub(/[&'<]/, "_"),
        "extdatasets" => datasets.to_s,
        "extversion" => env
      }

      options["image_url"] = image_url("icard")
      
      return @api.post_app_generate(@application_id, "info_card", options)
    end
    
    def extension(type, name, author, description)
      options = {
        "extname" => name,
        "extdesc" => description,
        "extauthor" => author.blank? ? @user.name : author
      }
      options["appguid"] = @guid if type == :ie
      return @api.post_app_generate(@application_id, type.to_s, options)
      
    end
    
    private
  
    def gen_default_krl
      r = "ruleset #{@application_id} {\n#{@meta}\n#{@dispatch}\n#{@global}\n#{@first_rule}}"
      return r
    end
    
    def load_base
      app_details = @api.get_app_details(@application_id)
      puts "APPDETAILS: #{app_details.inspect}"
      @name = app_details["name"]
      @application_id = app_details["appid"]
      @guid = app_details["guid"]
      @owner = nil
      @users = app_details["users"]
      @users.each do |user|
        if user["role"] == "owner"
          @owner = user 
          break
        end
      end
      @transfer_request = app_details["transferrequest"]
      @transfer_request = nil unless @transfer_request
      @invites = app_details["invites"]
      @invites = [] unless @invites
      @images = app_details["images"]
      @images = [] unless @images
    end
  
  
    def load_versions
      app_info = @api.get_app_info(@application_id)
      puts "APPINFO: #{app_info.inspect}"
      @production_version = app_info["production"]["version"] if app_info["production"]
      @development_version = app_info["development"]["version"] if app_info["development"]
      @application_id = app_info["appid"]
      @versions = app_info["versions"]
    end
    
    def set_krl(krl)
      # ensure that the ruleset_id is correct.
      krl.gsub!(/ruleset.*?\{/m, "ruleset #{@application_id} {")  
      puts "NEW KRL: #{krl}" 
      response = @api.post_app_source(@application_id, krl, "krl")
      response = JSON.parse(response)
      if response["valid"]
        reload
        return true
      else
        raise response["error"]
      end
    end
  

  end
end


