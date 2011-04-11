require File.expand_path(File.dirname(__FILE__) + '/../rbsh/builtins.rb')
require File.expand_path(File.dirname(__FILE__) + '/../rbsh/constants.rb')
require File.expand_path(File.dirname(__FILE__) + '/../rbsh/context.rb')

# all shell commands are run within an instance of the Shell class
# any variables and methods defined in this class will be directly
# available to the end user
class Shell
  include Rbsh::Builtins
  
  def initialize
    Rbsh::Context.binding = binding
    reload!
    @OLD_PWD ||= @PWD
    nil
  end
  
  def reload!
    @PWD ||= ENV['PWD']
    @HOME ||= ENV['HOME']
    @PS1 ||= Rbsh::Constants.const_get(:DEFAULT_PROMPT)
    @SHELL = File.expand_path $0
    source(@HOME + '/.rbshrc')
    source(@HOME + '/.rbshrc.rb')
    return true
  end

  def self.alias(sym, cmd)
    define_method sym do |*args|
      arg = *args
      if arg.nil? || arg.empty?
        system cmd
      else
        system "#{cmd} #{arg.first}"
      end
      nil
    end
  end

  def system_call(command)
    sys_output = system "#{command}"
    puts "[rbsh] error with command: #{command.split(' ').first}" unless sys_output
    sys_output
  end
  
end
