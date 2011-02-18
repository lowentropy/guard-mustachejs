require 'guard'
require 'guard/guard'

module Guard
  class MustacheJsGuard < Guard

    def initialize(watchers = [], options = {})
      super(watchers, {
        :variable => 'mustache_templates',
        :output => 'public/javascripts/mustache-templates.js'
      }.merge(options))
    end
    
    def start
      write_template read_template
    end
    
    def run_on_change(paths)
      write_template modify_template(read_template, paths)
    end
    
    def run_all
      run_on_change(Watcher.match_files(self, Dir.glob(File.join('**', '*'))))
    end

    private
    
    def read_template
      declaration = "var #{options[:variable]} = {};"
      template = File.read(options[:output]) if File.exists?(options[:output])
      write_once(template || "", declaration)
    end
    
    def write_once(template, line)
      template.tap { template << line << "\n" unless template.include? line }
    end
    
    def write_template(template)
      file = File.open(options[:output], 'w')
      file.puts template
      file.close
    end
    
    def modify_template(template, paths)
      paths.each do |path|
        key, raw = convert_to_js path
        key = key.split '/'
        key.unshift options[:variable].clone
        write_key_value template, key, raw
      end
      notify paths
      template
    end
    
    def write_key_value(template, key, value)
      prefix = key.shift
      until key.empty?
        part = key.shift
        prefix << '.' << part
        write_once template, "#{prefix} = #{key.any? ? '{}' : value};"
      end
    end
    
    def notify(paths)
      message = "Added to #{options[:output]}: #{paths.join(', ')}"
      ::Guard::Notifier.notify message, :title => "MustacheJS"
    end
    
    def convert_to_js(path)
      watchers.each do |watcher|
        if match = path.match(watcher.pattern)
          unless base_name = match[1]
            raise "No capture groups in guard pattern for mustache"
          end
          js = File.read(path).inspect
          return base_name.gsub(/[-.]/,'_'), js
        end
      end
      raise "No matcher matched '#{path}'"
    end
    
  end
end