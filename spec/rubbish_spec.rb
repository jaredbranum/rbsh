require File.expand_path(File.dirname(__FILE__) + '/../app/rubbish')

describe Rubbish do
  before do
    @rubbish = Rubbish.new
  end
  
  it "should send() user input as a method" do
    Readline.stub!(:readline).and_return("public_methods", nil)
    @rubbish.should_receive(:send).with(:public_methods)
    @rubbish.main
  end
  
  it "should call method_missing for unknown commands" do
    Readline.stub!(:readline).and_return("ls", nil)
    @rubbish.should_receive(:method_missing).with(:ls)
    @rubbish.main
  end
  
  describe "method_missing" do
    it "should call system()" do
      @rubbish.should_receive(:system).with('pwd')
      @rubbish.method_missing(:pwd)
    end
  end
end