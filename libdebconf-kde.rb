#!/usr/bin/env ruby

NAME      = "libdebconf-kde"
COMPONENT = "extragear"
SECTION   = "sysadmin"

$srcvcs   = "git"

def custom
    src_dir
    remover([
#        "junk","morejunk",".hiddenjunk"
    ])
    base_dir
end

$options = {:barrier=>75}

require_relative 'lib/starter'
