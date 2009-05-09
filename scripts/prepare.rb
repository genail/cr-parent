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

new_projects = false

projects.each do |project|
    if (not File.exists? project)
        notice "Got new project: #{project}"
    
        exec "git clone #{CONFIG::PUBLIC_REPO_URL}/#{project}.git #{project}"
        new_projects = true
    end
end

if (not new_projects)
    notice "No new projects to clone"
end
