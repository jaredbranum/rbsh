require './lib/rbsh_helper'

class Shell
  include RbshBuiltins
  
  def initialize
    @PWD ||= ENV['PWD']
    @HOME ||= ENV['HOME']
    @PS1 ||= 'rbsh-0.1$ '
    begin
      eval(File.new(@HOME + '/.rbshrc').read, context)
    rescue Errno::ENOENT
    rescue SyntaxError
      RbshHelper.rbshrc_syntax_error
    end
    begin
      eval(File.new(@HOME + '/.rbshrc.rb').read, context)
    rescue Errno::ENOENT
    rescue SyntaxError
      RbshHelper.rbshrc_syntax_error
    end
    @PWD ||= ENV['PWD']
    @OLD_PWD ||= @PWD
    @SHELL = File.expand_path $0
    instance_variables.each do |var|
      ENV[var[1..-1]] = instance_variable_get(var)
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