mods = []
mod = nil
File.readlines('.gitmodules').each do |line|
    case line
    when /\[submodule "([^"]+)"\]/
        mods << mod if mod
        mod = {name: $1}
    when /(\w+) = (.*)/
        mod[$1.to_sym] = $2
    end
end
mods << mod if mod

def act(mod, cmd)
    Dir.chdir(mod[:path]) do
        puts("[#{mod[:name]}] $ #{cmd}")
        r = `#{cmd}`
        puts(r)
        r
    end
rescue => e
    warn(e)
end

mods.each do |mod|
    next unless mod[:branch]
    act(mod, "git checkout #{mod[:branch]}")
end