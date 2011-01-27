require File.expand_path(File.dirname(__FILE__) + '/../app/rubbish')

describe Rubbish do
  before do
    @rubbish = Rubbish.new
  end
  
  it "should eval() user input unless special conditions are met" do
    Readline.stub!(:readline).and_return("public_methods", nil)
    @rubbish.should_receive(:eval).with('public_methods')
    @rubbish.main
  end
  
  it "should call system for unknown commands" do
    Readline.stub!(:readline).and_return("echo hi", nil)
    @rubbish.should_receive(:system).with('echo hi').and_return(true)
    @rubbish.main
  end
  
  # describe "method_missing" do
  #   it "should call system()" do
  #     @rubbish.should_receive(:system).with('pwd').and_return(true)
  #     @rubbish.method_missing(:pwd)
  #   end
  # end
  
  describe "cd" do
    it "should change to the target directory" do
      @rubbish.cd('/')
      Dir.pwd.should == '/'
    end
    
    it "should change to the user's home dir when no argument is passed" do
      @rubbish.cd
      Dir.pwd.should == Etc.getpwuid.dir
    end
    
    it "should change to the user's home dir when ~ is passed" do
      @rubbish.cd('~')
      Dir.pwd.should == Etc.getpwuid.dir
    end
    
    it "should allow the use of ~ in dir paths" do
      @rubbish.cd('~/..')
      Dir.pwd.should == Etc.getpwuid.dir.gsub(/\/[^\/]+$/, '')
    end
    
    it "should go back to the previous dir when called with -" do
      @rubbish.cd('/bin')
      @rubbish.cd('/')
      @rubbish.cd('-')
      Dir.pwd.should == '/bin'
    end
  end
end