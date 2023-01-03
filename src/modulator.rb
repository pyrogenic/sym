# frozen_string_literal: true

require 'rainbow/refinement'
using Rainbow

def parse_modules
  mods = []
  mod = nil
  File.readlines('.gitmodules').each do |line|
    case line
    when /\[submodule "(?<name>[^"]+)"\]/
      mods << mod if mod
      mod = { name: Regexp.last_match[:name] }
    when /(?<prop>\w+) = (?<value>.*)/
      mod[Regexp.last_match[:prop].to_sym] = Regexp.last_match[:value]
    end
  end
  mods << mod if mod
  mods
end

def act(mod, cmd)
  Dir.chdir(mod[:path]) do
    puts("[#{mod[:name].green}] #{'$'.faint} #{cmd}")
    r = `#{cmd}`
    puts(r.faint)
    r
  end
rescue StandardError => e
  warn(e)
end

def checkout_main
  mods.each do |mod|
    unless mod[:branch]
      puts("[#{mod[:name].red}] No branch defined!")
      next
    end
    act(mod, "git checkout #{mod[:branch]}")
  end
end

checkout_main
# TODO: Dependency order to execute things like tsc
