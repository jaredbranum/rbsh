require File.expand_path(File.dirname(__FILE__) + '/../lib/rbsh/builtins.rb')

class Shell
  ENV['HOME'] = '/home/test'
  include Rbsh::Builtins
end

describe Rbsh::Builtins do
  before do
    @shell = Shell.new
  end
  
  describe "sudo!!" do
    it "should execute the last command entered as root as a system command" do
      Readline::HISTORY = []
      Readline::HISTORY.push('ls')
      Readline::HISTORY.push('sudo!!')
      @shell.should_receive(:system).with("sudo ls")
      @shell.send(:"sudo!!")
    end
    
    it "should execute commands with command line arguments" do
      Readline::HISTORY = []
      Readline::HISTORY.push('ls -a -l /')
      Readline::HISTORY.push('sudo!!')
      @shell.should_receive(:system).with("sudo ls -a -l /")
      @shell.send(:"sudo!!")
    end
    
    it "should not execute ruby code" do
      @shell.should_receive(:system)
      @shell.should_not_receive(:eval)
      @shell.send(:"sudo!!")
    end
  end
  
  describe "bash" do
    it "should write the bash command to a file and exit" do
      File.should_receive(:open).with('/home/test/.rbsh_bash_command', 'w')
      @shell.should_receive(:exit).with(2)
      @shell.bash! 'echo $PWD'
    end
  end
  
  describe "rvm" do
    it "should execute rvm commands through bash" do
      @shell.should_receive(:bash!).with('rvm 1.8.7')
      @shell.rvm '1.8.7'
    end
  end
  
  describe "source" do
    it "should return false if no file is given" do
      @shell.source.should be_false
    end
    
    it "should return false if the file given does not exist" do
      File.should_receive(:read).and_raise(Exception)
      @shell.source('/path/to/fake/file').should be_false
    end
    
    it "should return false if the file given raises exceptions" do
      File.should_receive(:expand_path).with('bad.rb').and_return('./bad.rb')
      File.should_receive(:read).with('./bad.rb').and_return('bad = syntax')
      @shell.source('bad.rb').should be_false
    end
    
    it "should eval the file if it exists and return true if there are no exceptions" do
      File.should_receive(:expand_path).with('lol.rb').and_return('./lol.rb')
      File.should_receive(:read).with('./lol.rb').and_return('lol = 100')
      @shell.should_receive(:eval).with('lol = 100', Rbsh::Context.binding)
      @shell.source('lol.rb').should be_true
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