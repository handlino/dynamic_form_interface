# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "dynamic_form_interface"
  s.summary = "Insert DynamicFormInterface summary."
  s.description = "Insert DynamicFormInterface description."
  s.files = Dir["{app,lib,config}/**/*"] + ["Rakefile", "Gemfile", "README.md"]
  s.version = "0.0.1"
  s.authors     = ["tka@handlino"]
  s.email       = ["tka@handlino.com"]
  s.homepage    = "http://handlino.com"
  s.add_dependency('carrierwave')
  s.add_dependency('mini_magick')
  s.add_development_dependency("yard")
end
