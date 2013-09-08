# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "github-markup"
  s.version = "0.7.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Wanstrath"]
  s.date = "2012-12-17"
  s.description = "  This gem is used by GitHub to render any fancy markup such as\n  Markdown, Textile, Org-Mode, etc. Fork it and add your own!\n"
  s.email = "chris@ozmm.org"
  s.executables = ["github-markup"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["bin/github-markup", "README.md", "LICENSE"]
  s.homepage = "https://github.com/github/markup"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "The code GitHub uses to render README.markup"
end
