# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{eventmachine}
  s.version = "0.12.11"
  s.platform = 'x86-mswin32-60' if RUBY_PLATFORM=~/win32/
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Francis Cianfrocca"]
  s.date = %q{2010-04-29}
  s.description = %q{EventMachine implements a fast, single-threaded engine for arbitrary network
communications. It's extremely easy to use in Ruby. EventMachine wraps all
interactions with IP sockets, allowing programs to concentrate on the
implementation of network protocols. It can be used to create both network
servers and clients. To create a server or client, a Ruby program only needs
to specify the IP address and port, and provide a Module that implements the
communications protocol. Implementations of several standard network protocols
are provided with the package, primarily to serve as examples. The real goal
of EventMachine is to enable programs to easily interface with other programs
using TCP/IP, especially if custom protocols are required.
}
  s.email = %q{garbagecat10@gmail.com}
  s.extensions = ["ext/extconf.rb", "ext/fastfilereader/extconf.rb"] unless RUBY_PLATFORM=~/win32/
  s.has_rdoc = true

  candidates = Dir.glob("{docs,examples,ext,java,lib,tasks,tests,web}/**/*") +
               ["README", "Rakefile", "eventmachine.gemspec", "setup.rb", "java/.classpath", "java/.project"]
  s.files = candidates.delete_if do |item|
    item.include?("Makefile") || item.include?("rubyeventmachine-i386-mswin32.def")
  end
  s.files.sort!

  s.homepage = %q{http://rubyeventmachine.com}
  s.rdoc_options = ["--title", "EventMachine", "--main", "README", "--line-numbers", "-x", "lib/em/version", "-x", "lib/emva", "-x", "lib/evma/", "-x", "lib/pr_eventmachine", "-x", "lib/jeventmachine"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{eventmachine}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby/EventMachine library}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
