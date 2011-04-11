require File.expand_path(File.dirname(__FILE__) + '/../lib/rbsh/rbsh.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/rbsh/constants.rb')
include Rbsh::Constants

describe Rbsh do
  before do
    ENV['HOME'] = '/home/test'
    @rbsh = Rbsh.new
  end
  
  describe "main" do
    before do
      @rbsh.stub!(:running? => false)
      @rbsh.stub!(:accept_input)
    end
    
    it "should accept a single command-line argument" do
      Readline.stub!(:readline).and_return(nil)
      @rbsh.should_receive(:execute_command).with("cd")
      @rbsh.main(["cd"])
    end
    
    it "should accept multiple command-line arguments" do
      Readline.stub!(:readline).and_return(nil)
      @rbsh.should_receive(:execute_command).with("ls")
      @rbsh.should_receive(:execute_command).with("echo hello")
      @rbsh.should_receive(:execute_command).with("a = 5")
      @rbsh.main(["ls", "echo hello", "a = 5"])
    end
  end
  
  describe "accept_input" do
    before do
      File.stub!(:open)
    end
    
    it "should call execute_command for ruby user input" do
      Readline.stub!(:readline).and_return("public_methods(false).length", nil)
      @rbsh.should_receive(:execute_command).with("public_methods(false).length")
      @rbsh.accept_input
    end
    
    it "should call execute_command for system user input" do
      Readline.stub!(:readline).and_return("ls -a | wc -l", nil)
      @rbsh.should_receive(:execute_command).with("ls -a | wc -l")
      @rbsh.accept_input
    end
  end
  
  describe "execute_command" do
    it "should exit when the input is nil (Ctrl-D)" do
      @rbsh.should_receive(:exit)
      @rbsh.execute_command(nil)
    end
    
    it "should enter multi-line mode when the input is '#'" do
      @rbsh.should_receive(:multi_line)
      @rbsh.execute_command('#')
    end
    
    it "should do nothing when the input is empty (blank line)" do
      @rbsh.should_receive(:execute_command).and_return
      @rbsh.execute_command(nil)
    end
    
    describe "shell methods without parenthesized arguments" do
      it "should send shell methods if the shell implements that method" do
        @rbsh.shell.should_receive(:cd)
        @rbsh.execute_command('cd')
      end
      
      it "should send one argument as a string" do
        @rbsh.shell.should_receive(:cd).with('..')
        @rbsh.execute_command('cd ..')
      end
      
      it "should send multiple arguments as a single string" do
        @rbsh.shell.should_receive(:quit).with('a b c d')
        @rbsh.execute_command('quit a b c d')
      end
      
      it "should re-raise SystemExit exceptions" do
        @rbsh.shell.should_receive(:quit).and_raise(SystemExit)
        lambda { @rbsh.execute_command('quit') }.should raise_error(SystemExit)
      end
    end
    
    # TODO: tests for eval and system calls (important!)
    
    it "should output the result of ruby commands" do
      @rbsh.should_receive(:puts).with("=> 5")
      @rbsh.execute_command('5')
    end
    
    it "should not output the result of ruby commands if the result is nil" do
      @rbsh.should_not_receive(:puts)
      @rbsh.execute_command('nil')
    end
    
    it "should output the result of ruby commands if the result is false" do
      @rbsh.should_receive(:puts).with("=> false")
      @rbsh.execute_command('1 == 2')
    end
    
    it "should not output the result of shell commands" do
      @rbsh.should_not_receive(:puts)
      @rbsh.execute_command('echo shell command')
    end
    
    it "should evaluate all ruby commands within the same context (binding)" do
      @rbsh.should_receive(:puts).with('=> 573')
      @rbsh.execute_command('num = 573')
      @rbsh.should_receive(:puts).with('=> 613')
      @rbsh.execute_command('num + 40')
    end
  end
  
  describe "set_environment_variables" do
    it "should set all shell instance variables to ENV hash values" do
      @rbsh.set_environment_variables
      ENV['PS1'].should == DEFAULT_PROMPT
    end
  end
  
  describe "save_command_to_history" do
    it "should save your commands to a history file" do
      File.should_receive(:open).with('/home/test/.rbsh_history', 'a')
      @rbsh.save_command_to_history('pwd')
    end
    
    it "should save your commands to the Readline history" do
      File.stub!(:open)
      Readline::HISTORY.should_receive(:push).with('pwd')
      @rbsh.save_command_to_history('pwd')
    end
    
    it "should not save empty strings or nil values" do
      File.should_not_receive(:open)
      Readline::HISTORY.should_not_receive(:push)
      @rbsh.save_command_to_history('')
    end
  end
  
end