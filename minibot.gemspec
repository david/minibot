GEM = "minibot"
VERSION = "0.0.1"
AUTHOR = "David Leal"
EMAIL = "dgleal@gmail.com"
HOMEPAGE = "http://davidleal.com"
SUMMARY = "A mini Ruby IRC bot framework"

SPEC = Gem::Specification.new do |s|
  s.name = GEM
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README TODO Rakefile) + Dir.glob("{lib,specs}/**/*")
end
