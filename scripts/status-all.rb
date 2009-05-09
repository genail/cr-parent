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

project_list_file = File.new("project-list")
projects = project_list_file.read().split("\n")
project_list_file.close()

projects.push(".")

clean = true

projects.each do |project|
    #notice "checking project #{project}"
    result = `cd #{project}; git status`
    
    if (result.index("nothing to commit") == nil)
        notice "#{project} has uncommited changes"
        clean = false
    end
end

if (clean)
    notice "All repositories are clean :-)"
end
