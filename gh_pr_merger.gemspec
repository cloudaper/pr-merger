lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gh_pr_merger/version'

Gem::Specification.new do |spec|
  spec.name          = 'gh_pr_merger'
  spec.version       = GhPrMerger::VERSION
  spec.authors       = ['Tibor Szolár']
  spec.email         = ['tibor.szolar@seznam.cz']

  spec.summary       = %q{Merges all opened GitHub PRs to a new branch.}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/cloudaper/gh_pr_merger'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'octokit', '~> 4.0'
  spec.add_runtime_dependency 'tty-command', '~> 0.2'
end
