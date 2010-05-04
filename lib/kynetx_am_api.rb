require File.dirname(__FILE__) + '/kynetx_am_api/direct_api.rb'
require File.dirname(__FILE__) + '/kynetx_am_api/oauth.rb'
require File.dirname(__FILE__) + '/kynetx_am_api/user.rb'
require File.dirname(__FILE__) + '/kynetx_am_api/application.rb'


DEFAULT_META = <<-KRL
  meta {
    name "<<NAME>>"
    description <<
      <<DESCRIPTION>>
    >>
    author ""
    // Uncomment this line to require Markeplace purchase to use this app.
    // authz require user
    logging off
  }
KRL

DEFAULT_GLOBAL = <<-KRL
  global {
  
  }
KRL

DEFAULT_DISPATCH = <<-KRL
  dispatch {
    // Some example dispatch domains
    // www.exmple.com
    // other.example.com
  }
KRL

DEFAULT_RULE = <<-KRL
  rule <<NAME>> is active {
    select using "" setting ()
    // pre {   }
    // notify("Hello World", "This is a sample rule.");
    noop();
  }
KRL