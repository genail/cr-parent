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

notice "New Coral Reef / GIT project creation script"

name = nil
long_name = nil
version = nil
dependencies = nil

begin

    name = prompt("Library name (eg. cr-network)", /^[^ ]+$/);
    long_name = prompt("Library long name (eg. Network library)", /.+/);
    version = prompt("Library version [0.1-SNAPSHOT]", /.+/, "0.1-SNAPSHOT")
    dependencies = prompt("Library dependencies (for README)", /.*/);

    puts
    puts "Summary:"
    puts "Library name: #{name}"
    puts "Library long name: #{long_name}"
    puts "Library version: #{version}"
    print "Library dependencies: "
    
    if (dependencies.empty?)
        puts "none"
    else
        puts dependencies
    end
    
    puts

    isok = prompt("Is that ok? [yes/no]", /^(yes)|(no)$/)
end while (isok == "no")

require_env_variable "EDITOR"

require_file "pom.xml.template"
require_file "gitignore.template"
require_file "README.template"

require_app "git"

if (File.exists? name)
    error("cannot create directory '#{name}': file already exists")
end

replace = {}
replace["[[name]]"] = name
replace["[[long_name]]"] = long_name
replace["[[version]]"] = version
replace["[[dependencies]]"] = dependencies


mkdir name
cp_template "pom.xml.template", "#{name}/pom.xml", replace
cp_template "gitignore.template", "#{name}/.gitignore"
cp_template "README.template", "#{name}/README", replace

mkdir "#{name}/src"
mkdir "#{name}/src/main"
mkdir "#{name}/src/main/java"
mkdir "#{name}/src/main/resources"
mkdir "#{name}/src/test"
mkdir "#{name}/src/test/java"
mkdir "#{name}/src/test/resources"

exec "cd #{name}; git init"

# add to project-list file
notice "Adding project entry to project-list file"
project_list_file = File.new("project-list", "a")
project_list_file.write("\n#{name}")
project_list_file.close()

notice "Adding project entry to parent .gitignore file"
project_list_file = File.new(".gitignore", "a")
project_list_file.write("\n#{name}")
project_list_file.close()

puts
create_public_repo = prompt("Project created. Do you also want to create a public GIT repository? [yes/no]", /^(yes)|(no)$/)

if (create_public_repo == "yes")

    public_repo = "#{CONFIG::PUBLIC_REPO_DIR}/#{name}.git"

    exec "git clone --bare #{name} #{public_repo}"
    exec "cd #{name}; git remote add origin #{public_repo}"
    exec "cd #{public_repo}; git --bare update-server-info; mv hooks/post-update.sample hooks/post-update"
    
    puts
    notice "Your public repo has been successfully created!"
    notice "It's location is #{CONFIG::PUBLIC_REPO_URL}/#{name}.git"
end

open_parent_pom = prompt("You should add new project to parent pom.xml. Do you want to do this now? [yes/no]", /^(yes)|(no)$/)

if (open_parent_pom == "yes")
    system("#{ENV["EDITOR"]} pom.xml")
end

notice "All done :-)"
