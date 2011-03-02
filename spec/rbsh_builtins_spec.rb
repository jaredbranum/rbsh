require File.expand_path(File.dirname(__FILE__) + '/../lib/rbsh_builtins.rb')

class Shell
  ENV['HOME'] = '/home/test'
  include RbshBuiltins
end

describe RbshBuiltins do
  before do
    @shell = Shell.new
  end
  
  describe "rvm" do
    it "should write the rvm command to a file and exit" do
      File.should_receive(:open).with('/home/test/.rbsh_bash_command', 'w')
      @shell.should_receive(:exit).with(2)
      @shell.rvm '1.8.7'
    end
  end
  
  describe "quit" do
    it "should exit the shell" do
      @shell.should_receive(:exit).with(0)
      @shell.quit
    end
  end
  
  describe "cd" do
    it "should change to the target directory" do
      Dir.should_receive(:chdir).with('/')
      @shell.cd('/')
    end
    
    it "should change to the user's home dir when no argument is passed" do
      Dir.should_receive(:chdir).with(ENV['HOME'])
      @shell.cd
    end
    
    it "should change to the user's home dir when ~ is passed" do
      Dir.should_receive(:chdir).with(ENV['HOME'])
      @shell.cd('~')
    end
    
    it "should allow the use of ~ in dir paths" do
      Dir.should_receive(:chdir).with(ENV['HOME'] + '/..')
      @shell.cd('~/..')
    end
    
    it "should go back to the previous dir when called with -" do
      Dir.should_receive(:chdir).with('/home')
      @shell.cd('/home')
      Dir.stub!(:pwd => '/home')
      Dir.should_receive(:chdir).with('/')
      @shell.cd('/')
      Dir.stub!(:pwd => '/')
      Dir.should_receive(:chdir).with('/home')
      @shell.cd('-')
    end
  end
  
end