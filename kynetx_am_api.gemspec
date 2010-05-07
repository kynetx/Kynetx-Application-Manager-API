require 'rake'

Gem::Specification.new do |s|
  s.name = %q{kynetx_am_api}
  s.version = "0.1.24"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Farmer, Cid Dennis"]
  s.date = %q{2010-05-07}
  s.email = %q{cid@kynetx.com}
  s.extra_rdoc_files = ["LICENSE"]
  s.homepage = %q{http://www.kynetx.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.has_rdoc = true
  s.summary = %q{Simple Gem used to communicate with the Kynetx Application Manager.}

  s.description = <<-EOF
    Using this gem you can access the Kynetx Application API.  This api allows developers a way
    to create,update, delete rulesets.   This gem also helps with the required OAuth communcations with
    the api server.
  EOF

  s.files = FileList['lib/**/*.rb', 'rails/**/*', 'spec/**/*', 'init.rb', 'Rakefile',"LICENSE"].to_a

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<multipart-post>, [">= 0"])
      s.add_development_dependency('rspec')
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<multipart-post>, [">= 0"])
      s.add_development_dependency('rspec')
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<multipart-post>, [">= 0"])
    s.add_development_dependency('rspec')
  end
end
