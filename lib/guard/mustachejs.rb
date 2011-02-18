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
      if File.exists? options[:output]
        File.read(options[:output]).sub /^var .*/, declaration
      else
        "#{declaration}\n\n"
      end
    end
    
    def write_template(template)
      file = File.open(options[:output], 'w')
      file.puts template
      file.close
    end
    
    def modify_template(template, paths)
      paths.each do |path|
        key, raw = convert_to_js path
        prefix = "#{options[:variable]}['#{key}'] = "
        re = /^#{Regexp.escape(prefix)}.*/
        if template =~ re
          template.gsub re, raw
        else
          template << prefix << raw << ";\n"
        end
      end
      template
    end
    
    def convert_to_js(path)
      watchers.each do |watcher|
        if match = path.match(watcher.pattern)
          unless base_name = match[1]
            raise "No capture groups in guard pattern for mustache"
          end
          js = File.read(path).inspect
          return base_name, js
        end
      end
      raise "No matcher matched '#{path}'"
    end
    
  end
end