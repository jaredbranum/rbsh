require File.expand_path(File.dirname(__FILE__) + '/../app/rbsh')

describe Rbsh do
  before do
    @shell = Rbsh.new
  end
  
  it "should eval() user input unless special conditions are met" do
    Readline.stub!(:readline).and_return("public_methods", nil)
    @shell.should_receive(:eval).with('public_methods')
    @shell.main
  end
  
  it "should call system for unknown commands" do
    Readline.stub!(:readline).and_return("echo hi", nil)
    @shell.should_receive(:system).with('echo hi').and_return(true)
    @shell.main
  end
  
  # describe "method_missing" do
  #   it "should call system()" do
  #     @shell.should_receive(:system).with('pwd').and_return(true)
  #     @shell.method_missing(:pwd)
  #   end
  # end
  
  describe "cd" do
    it "should change to the target directory" do
      @shell.cd('/')
      Dir.pwd.should == '/'
    end
    
    it "should change to the user's home dir when no argument is passed" do
      @shell.cd
      Dir.pwd.should == Etc.getpwuid.dir
    end
    
    it "should change to the user's home dir when ~ is passed" do
      @shell.cd('~')
      Dir.pwd.should == Etc.getpwuid.dir
    end
    
    it "should allow the use of ~ in dir paths" do
      @shell.cd('~/..')
      Dir.pwd.should == Etc.getpwuid.dir.gsub(/\/[^\/]+$/, '')
    end
    
    it "should go back to the previous dir when called with -" do
      @shell.cd('/bin')
      @shell.cd('/')
      @shell.cd('-')
      Dir.pwd.should == '/bin'
    end
  end
end