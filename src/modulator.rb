require 'rainbow/refinement'
using Rainbow

mods = []
mod = nil
File.readlines('.gitmodules').each do |line|
  case line
  when /\[submodule "([^"]+)"\]/
    mods << mod if mod
    mod = { name: Regexp.last_match(1) }
  when /(\w+) = (.*)/
    mod[Regexp.last_match(1).to_sym] = Regexp.last_match(2)
  end
end
mods << mod if mod

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

mods.each do |mod|
  unless mod[:branch]
    puts("[#{mod[:name].red}] No branch defined!")
    next
  end

  act(mod, "git checkout #{mod[:branch]}")
end
