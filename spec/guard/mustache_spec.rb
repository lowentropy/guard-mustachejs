require 'spec_helper'

describe Guard::MustacheJsGuard do
  
  let(:watcher) { Guard::Watcher.new('^x/.+\.html') }
  
  describe "#initialize" do
    context "with no options provided" do
      subject { Guard::MustacheJsGuard.new }
      its(:options) { should == {
        :variable => 'mustache_templates',
        :output => 'public/javascripts/mustache-templates.js'
      }}
    end
    
    context "with custom options" do
      before { @opts = {
        :variable => 'templates',
        :output => 'public/javascripts/my_templates.js'
      }}
      subject { Guard::MustacheJsGuard.new(nil, @opts) }
      its(:options) { should == @opts }
    end
  end
  
  describe '#run_on_change' do
    subject { Guard::MustacheJsGuard.new [watcher] }    
    it 'runs the run_on_change with all watched files' do
      subject.should_receive(:run_all)
      subject.run_on_change [:foo, :bar, :baz]
    end
  end
  
  describe "#start" do
    subject { Guard::MustacheJsGuard.new }
    let(:output_path) { "public/javascripts/mustache-templates.js" }
    context "for the first time" do
      it 'creates a default output file' do
        assert_file_absent output_path
        assert_writes output_path, "var mustache_templates = {};\n"
        subject.start
      end
    end
    context "with an existing template file" do
      let(:declaration) { "var mustache_templates = {};" }
      it 'modifies the first line' do
        assert_file_present output_path
        subject.start
      end
    end
  end
  
  describe "#run_on_change" do
    let(:patterns)    { [%r{app/mustache/(.+).html}, %r{app/mustache/(.*)}] }
    let(:watchers)    { patterns.map {|p| Guard::Watcher.new(p) }}
    let(:paths)       { ['app/mustache/x/y/foo.html', 'app/mustache/x/z/bar-baz.js'] }
    let(:template)    { '{{#user}}<p>Hi, {{name}}</p>{{/user}}' }
    let(:output_path) { "public/javascripts/mustache-templates.js" }
    let(:message)     { "#{output_path}:\n\n#{paths.join("\n")}" }
    let(:output)      { <<-OUTPUT }
var mustache_templates = {};
mustache_templates.x = {};
mustache_templates.x.y = {};
mustache_templates.x.y.foo = "#{template}";
mustache_templates.x.z = {};
mustache_templates.x.z.bar_baz_js = "#{template}";
OUTPUT
    
    before { Dir.stub!(:glob).and_return(paths) }
    subject { Guard::MustacheJsGuard.new watchers }

    it 'should write the correct template' do
      assert_reads paths[0], template
      assert_reads paths[1], template
      assert_writes output_path, output
      assert_notifies message
      subject.run_on_change paths
    end
  end
  
  def assert_notifies(message)
    Guard::Notifier.should_receive(:notify).with(message, :title => 'MustacheJS')
  end
  
  def assert_file_present(path)
    File.should_receive(:exists?).with(path).and_return true
  end
  
  def assert_file_absent(path)
    File.should_receive(:exists?).with(path).and_return false
  end
  
  def assert_reads(path, content)
    File.should_receive(:read).with(path).and_return(content)
  end
  
  def assert_writes(path, content)
    File.should_receive(:open).with(path, 'w').and_return(file = mock)
    file.should_receive(:puts).with(content)
    file.should_receive(:close)
  end
end