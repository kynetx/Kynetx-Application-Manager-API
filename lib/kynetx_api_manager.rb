require 'kynetx_api_manager/kynetx_api'
require 'kynetx_api_manager/oauth'
require 'kynetx_api_manager/user'
require 'kynetx_api_manager/rule'
require 'kynetx_api_manager/application'


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