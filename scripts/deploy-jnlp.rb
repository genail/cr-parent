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

if (ARGV.size != 1)
    notice("Usage: ruby deploy-jnlp project_dir")
    exit 1
end

project_dir = ARGV[0]

if (not File.exists? project_dir)
    error("directory '#{project_dir}' doesn't exist");
end

if (not File.directory? project_dir)
    error("file '#{project_dir}' is not a directory");
end

require_app "mvn"
require_file "#{project_dir}/webstart-goals"

mkdir "#{CONFIG::JNLP_OUTPUT_DIR}/#{project_dir}"

# read the goals
goals_file = File.new("#{project_dir}/webstart-goals")
goals = goals_file.read().split("\n")
goals_file.close()

# make them
goals.each do |goal|

    if (goal.empty?)
        next
    end
    
    puts
    notice "Building webstart goal #{goal}"
    puts

    exec "cd #{project_dir}; mvn clean install org.codehaus.mojo.webstart:webstart-maven-plugin:jnlp -D#{goal}"
    
    Dir.new("#{project_dir}/target/jnlp").each do |file|
        if (file =~ /.*\.(jnlp)|(jar)$/)
            cp "#{project_dir}/target/jnlp/#{file}", "#{CONFIG::JNLP_OUTPUT_DIR}/#{project_dir}/#{file}"
        end
    end
    
end

puts
notice "All done!"
