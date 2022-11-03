require_relative "lib/supports_pointer/version"

Gem::Specification.new do |spec|
  spec.name        = "supports_pointer"
  spec.version     = SupportsPointer::VERSION
  spec.authors     = ["Greg Mikeska"]
  spec.email       = ["gmikeska07@gmail.com"]
  spec.summary       = "A rails plugin to add human-readable pointers to models and other data related objects."
  spec.description   = "A rails plugin to add human-readable pointers to models and other data related objects."
  spec.homepage      = "https://github.com/gmikeska/supports_pointer"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage+"/blob/master/CHANGELOG.MD"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.4"
end
