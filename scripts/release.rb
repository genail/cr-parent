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

require 'rexml/document'
include REXML

if (ARGV.size != 1)
    notice("Usage: ruby release.rb project_dir");
    exit 1
end

PROJECT_DIR = ARGV[0]

if (not File.exists? PROJECT_DIR)
    error("directory '#{PROJECT_DIR}' doesn't exist");
end

if (not File.directory? PROJECT_DIR)
    error("file '#{PROJECT_DIR}' is not a directory");
end

require_app "git"
require_app "mvn"
require_file "#{PROJECT_DIR}/pom.xml"

# check if project is clean
if (not clean?(PROJECT_DIR))
    puts "The project local repository has uncommited changes"
    exit 1
end

# read project version
pom = Document.new(File.new(PROJECT_DIR + "/pom.xml"))
root = pom.root
version = root.elements["version"].text

if (not version =~ /^[0-9]+\.[0-9]+-SNAPSHOT$/)
    error("expected a snapshot version but '#{version}' found");
end

# incrase last number by one
last_number = version.scan(/\.([0-9]+)-SNAPSHOT/)[0][0].to_i()
last_number = last_number + 1

# make default release version
release_version = version.gsub("-SNAPSHOT", "")

# and next development version
next_dev_version = version.gsub(/[0-9]+-SNAPSHOT/, "#{last_number}-SNAPSHOT")

u_release_version = nil
u_next_dev_version = nil
u_tag_name = nil

begin
    puts("#{PROJECT_DIR} version is #{version}");
    
    u_release_version = prompt("What will be this release version? [#{release_version}]", /.+/, release_version)
    u_tag_name = prompt("What will be the tag name? [v#{u_release_version}]", /.+/, "v#{u_release_version}")
    u_next_dev_version = prompt("What will be next development version? [#{next_dev_version}]", /.+/, next_dev_version)

    puts
    puts "Summary:"
    puts "This release version: #{u_release_version}"
    puts "Release tag name: #{u_tag_name}"
    puts "Next development version: #{u_next_dev_version}"

    isok = prompt("Is that ok? [yes/no]", /^(yes)|(no)$/)

end while (isok == "no")

# change version to release

root.elements["version"].text = u_release_version

# write the new pom file
file = File.new(PROJECT_DIR + "/pom.xml", "w")
file.write(pom)
file.close()

# commit and tag
if (not exec "cd #{PROJECT_DIR}; git commit -a -m \"* Release preparation\"")
    error "Cannot make a commit: aborting..."
    exit 1
end
exec "cd #{PROJECT_DIR}; git tag #{u_tag_name}"

# deploy to maven repository
notice "Deploying to Maven repository"

if (not exec "cd #{PROJECT_DIR}; mvn deploy")
    error "Error during deploying. Undoing commit..."
    exec "cd #{PROJECT_DIR}; git reset --soft HEAD^"
    exit 1
end

notice "Everything good so far..."
notice "Changing version to next development one"

root.elements["version"].text = u_next_dev_version

# write pom file again
file = File.new(PROJECT_DIR + "/pom.xml", "w")
file.write(pom)
file.close()

# commit again
if (not exec "cd #{PROJECT_DIR}; git commit -a -m \"* Version change to the next development stage\"")
    error "That's wired... Can't I commit next development version? Please check this out."
    exit 1
end

notice "Everything's done!"

