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
      write_template([]) unless File.exists?(options[:output])
    end
    
    def run_on_change(paths)
      run_all
    end
    
    def run_all
      paths = Watcher.match_files(self, Dir.glob(File.join('**', '*'))).uniq
      write_template paths
    end

    private
    
    def write_template(paths)
      template = "var #{options[:variable]} = {};\n"
      paths.each do |path|
        key, raw = convert_to_js path
        key.unshift options[:variable].clone
        write_key_value template, key, raw
      end
      file = File.open(options[:output], 'w')
      file.puts template
      file.close
      notify paths
    end
    
    def write_key_value(template, key, value)
      lhs = key.shift
      until key.empty?
        part = key.shift
        lhs << '.' << part
        rhs = key.any? ? '{}' : value
        line = "#{lhs} = #{rhs};\n"
        template << line unless template.include? line
      end
    end
    
    def notify(paths)
      message = "#{options[:output]}:\n\n#{paths.join("\n")}"
      ::Guard::Notifier.notify message, :title => "MustacheJS"
    end
    
    def convert_to_js(path)
      watchers.each do |watcher|
        if match = path.match(watcher.pattern)
          unless base_name = match[1]
            raise "No capture groups in guard pattern for mustache"
          end
          js = File.read(path).inspect
          key = base_name.gsub(/[-.]/,'_').split('/')
          return key, js
        end
      end
      raise "No matcher matched '#{path}'"
    end
    
  end
end