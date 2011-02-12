require './lib/rbsh_variables'
require './lib/rbsh_helper'
require './lib/rbsh_builtins'

class Shell
  include RbshBuiltins
  
  def initialize
    reload!
    
    @running ||= true
    @PWD ||= ENV['PWD']
    @OLD_PWD ||= @PWD
    nil
  end
  
  def reload!
    @PWD ||= ENV['PWD']
    @HOME ||= ENV['HOME']
    @PS1 ||= 'rbsh-0.1$ '
    @bind ||= binding
    begin
      eval(File.new(@HOME + '/.rbshrc').read, @bind)
    rescue Errno::ENOENT => e
    rescue SyntaxError => e
      RbshHelper.rbshrc_syntax_error
    end
    begin
      eval(File.new(@HOME + '/.rbshrc.rb').read, @bind)
    rescue Errno::ENOENT => e
    rescue SyntaxError => e
      RbshHelper.rbshrc_syntax_error
    end
    @SHELL = File.expand_path $0
    instance_variables.each do |var|
      ENV[var[1..-1]] = instance_variable_get(var) unless var.to_s == '@bind'
    end
    true
  end
  
  def context
    binding
  end
  
  def method_missing(sym, *args, &block)
    #if @running
      system_call
    #else
    #  RbshHelper.rbshrc_syntax_error
    #end
  end
end