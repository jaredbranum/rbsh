require './lib/rbsh_context'
require './lib/rbsh_builtins'

# all shell commands are run within an instance of the Shell class
# any variables and methods defined in this class will be directly
# available to the end user
class Shell
  include RbshBuiltins
  
  def initialize
    reload!
    
    RbshContext.binding = binding
    @OLD_PWD ||= @PWD
    return nil
  end
  
  def reload!
    @PWD ||= ENV['PWD']
    @HOME ||= ENV['HOME']
    @PS1 ||= 'rbsh-0.1$ '
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
      return nil
    end
  end

  def system_call(command)
    sys_output = system "#{command}"
    puts "[rbsh] error with command: #{command.split(' ').first}" unless sys_output
    return sys_output
  end
  
end
