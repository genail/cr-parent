#!/usr/bin/env ruby

if (!File.exists? "scripts")
    puts "This script must be called from CoralReef parent directory"
    exit 1
end

require 'scripts/common'

# make sure if config file is available
# if not then create one from template
prepare_config();

require 'scripts/config'

require_app "git"

projects = contents("project-list")
projects.push(".")

projects.each do |project|
    if (project.empty?)
        next
    end
    
    exec "cd #{project}; git pull"
end
