require './lib/rbsh_variables'
require './lib/rbsh_helper'
require './lib/rbsh_builtins'

# all shell commands are run within an instance of the Shell class
# any variables and methods defined in this class will be directly
# available to the end user
class Shell
  include RbshBuiltins
  attr_reader :PS1
  
  def initialize
    reload!
    
    RbshVariables.context = binding
    RbshVariables.running = true
    @PWD ||= ENV['PWD']
    @OLD_PWD ||= @PWD
    nil
  end
  
  def reload!
    @PWD ||= ENV['PWD']
    @HOME ||= ENV['HOME']
    @PS1 ||= 'rbsh-0.1$ '
    begin
      eval(File.new(@HOME + '/.rbshrc').read, RbshVariables.context)
    rescue Errno::ENOENT => e
    rescue SyntaxError => e
      RbshHelper.rbshrc_syntax_error
    end
    begin
      eval(File.new(@HOME + '/.rbshrc.rb').read, RbshVariables.context)
    rescue Errno::ENOENT => e
    rescue SyntaxError => e
      RbshHelper.rbshrc_syntax_error
    end
    @SHELL = File.expand_path $0
    true
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
    return if RbshVariables.system_command?
    sys_output = system "#{command}"
    RbshVariables.system_command = true
    puts "No command or method found: #{command}" unless sys_output
    return sys_output
  end
  
end
