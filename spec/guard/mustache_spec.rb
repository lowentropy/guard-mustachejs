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
  
  describe '#run_all' do
    subject { Guard::MustacheJsGuard.new [watcher] }    
    before { Dir.stub(:glob).and_return ['x/a.html', 'x/b.js', 'y/c.html'] }

    it 'runs the run_on_change with all watched files' do
      subject.should_receive(:run_on_change).with(['x/a.html'])
      subject.run_all
    end
  end
  
  describe "#start" do
    subject { Guard::MustacheJsGuard.new }
    let(:output_path) { "public/javascripts/mustache-templates.js" }
    before { @output_stub = mock }
    context "for the first time" do
      it 'creates a default output file' do
        assert_should_not_exist output_path
        assert_writes_to output_path, "var mustache_templates = {};\n\n"
        subject.start
      end
    end
    context "with an existing template file" do
      it 'modifies the first line' do
        assert_should_exist output_path
        assert_reads_from output_path, "var foo = bar;"
        assert_writes_to output_path, "var mustache_templates = {};"
        subject.start
      end
    end
  end
  
  describe "#run_on_change" do
    let(:watcher) { Guard::Watcher.new(%r{app/mustache/(.+).html}) }
    let(:paths) { ['app/mustache/x/y/foo.html'] }
    let(:template) { '{{#user}}<p>Hi, {{name}}</p>{{/user}}' }
    let(:output_path) { "public/javascripts/mustache-templates.js" }
    subject { Guard::MustacheJsGuard.new [watcher] }
    it 'should write the correct template' do
      assert_should_not_exist output_path
      assert_reads_from(paths[0], template)
      assert_writes_to(output_path, <<-OUTPUT)
var mustache_templates = {};

mustache_templates['x/y/foo'] = "#{template}";
      OUTPUT
      subject.run_on_change(paths)
    end
  end
  
  def assert_should_exist(path)
    File.should_receive(:exists?).with(path).and_return true
  end
  
  def assert_should_not_exist(path)
    File.should_receive(:exists?).with(path).and_return false
  end
  
  def assert_reads_from(path, content)
    File.should_receive(:read).with(path).and_return(content)
  end
  
  def assert_writes_to(path, content)
    File.should_receive(:open).with(path, 'w').and_return(file = mock)
    file.should_receive(:puts).with(content)
    file.should_receive(:close)
  end
end