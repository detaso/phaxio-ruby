require File.expand_path("../lib/phaxio/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ["Julien Negrotto"]
  gem.email = ["julien@phaxio.com"]
  gem.description = "Official ruby gem for interacting with Phaxio's API."
  gem.summary = "Official ruby gem for interacting with Phaxio's API."
  gem.homepage = "https://github.com/phaxio/phaxio-ruby"

  gem.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files = `git ls-files`.split("\n")
  gem.name = "phaxio"
  gem.require_paths = ["lib"]
  gem.version = Phaxio::VERSION
  gem.licenses = ["MIT"]

  gem.required_ruby_version = ">= 2.0"
  gem.add_dependency "faraday", "~> 2.0"
  gem.add_dependency "faraday-multipart", "~> 1.0"
  gem.add_dependency "mime-types", "~> 3.0"
  gem.add_dependency "activesupport"
end
