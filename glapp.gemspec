# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{glapp}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Lieber"]
  s.date = %q{2009-05-18}
  s.email = %q{tom@alltom.com}
  s.extra_rdoc_files = [
    "README.textile"
  ]
  s.files = [
    ".gitignore",
     "README.textile",
     "Rakefile",
     "VERSION",
     "examples/hedgehog.ppm",
     "examples/sprite.rb",
     "examples/triangles.rb",
     "examples/triangles2.rb",
     "glapp.gemspec",
     "lib/glapp.rb"
  ]
  s.homepage = %q{http://github.com/alltom/glapp}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{ruby-opengl wrapper for writing quick applets}
  s.test_files = [
    "examples/sprite.rb",
     "examples/triangles.rb",
     "examples/triangles2.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
