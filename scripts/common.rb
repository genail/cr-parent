require 'ftools'


def cp(from, to)
    notice("copying file from '#{from}' to '#{to}'");
    File.copy(from, to)
end

def cp_template(from, to, replace = nil)
    notice("copying template file from '#{from}' to '#{to}'");

    from_file = File.new(from)
    from_contents = from_file.read()
    from_file.close()
    
    if (replace != nil)
        replace.each_key do |key|
            from_contents.gsub!(key, replace[key]);
        end
    end
    
    to_file = File.new(to, "a")
    to_file.write(from_contents)
    to_file.close()    
end

def contents(filename)
    file = File.new(filename)
    c = file.read().split("\n")
    file.close()
    
    return c
end

def error(message)
    puts "Error:"
    puts "\t#{message}"
    exit 1
end

def exec(command)
    puts "# exec: #{command}"
    system(command)
end

def notice(message)
    puts "# #{message}"
end

def mkdir(dirname)
    notice("creating directory #{dirname}")
    Dir.mkdir(dirname)
end

def prepare_config()
    if (not File.exists? "scripts/config.rb")
        notice "Config file not found. Creating one from template."
        notice "The new config file should be ignored by GIT"
        cp("scripts/config.rb.template", "scripts/config.rb")
    end
end

def prompt(question, answer_regex, default_answer=nil)
    print "#{question}: "
    answer = gets.chop()
    
    if (answer.empty? and default_answer != nil)
        answer = default_answer
    end
    
    if (answer =~ answer_regex)
        return answer
    else
        return prompt(question, answer_regex, default_answer)
    end
end


def require_app(app_name)
    result = `#{app_name}`
    
    if (result.empty?)
        error("required application '#{app_name}' not found");
    end
end

def require_env_variable(name)
    if (not ENV.has_key? name)
        error("required enviorment variable '#{name}' not set");
    end
end

def require_file(filename)
    if (not File.exists? filename)
        error("required file '#{filename}' does not exist")
    end
end
