require 'readline'
require './lib/rbsh_helper'
require './lib/rbsh_variables'
require './lib/shell'

class Rbsh
  
  def initialize
    @shell ||= Shell.new
  end

  def self.alias(*args)
    Shell.alias(*args)
  end
  
  def main(argv=[])
    while RbshVariables.running?
      hostname = `hostname`.chomp.split('.').first
      if argv.empty?
        RbshVariables.command = Readline.readline(RbshHelper.parse_ps1(@shell.PS1), true)
        execute_command
      else
        argv.each do |cmd|
          RbshVariables.command = cmd
          execute_command
        end
        argv=[]
      end
    end
  end
  
  def execute_command
    if RbshVariables.command.nil?
      print "\n"
      exit
    elsif RbshVariables.command.strip == '#'
      multi_line
    else
      RbshVariables.system_command = false

      # special case for builtins
      split_com = RbshVariables.command.split(/\s+/, 2)
      if @shell.respond_to?(split_com.first)
        output = split_com.length == 1 ? @shell.send(split_com.first.to_sym) : @shell.send(split_com.first.to_sym, split_com.last)
      else
        begin
          output = eval(RbshVariables.command, RbshVariables.context)
          output = output.inspect unless output.nil?
        rescue NameError => e
          @shell.system_call
        rescue SyntaxError => e
          @shell.system_call
        rescue ArgumentError => e
          @shell.system_call
        end
      end

      if !RbshVariables.system_command? && output && !output.empty?
        puts '=> ' + output
      end
    end
    
  end
  
  def multi_line
    ruby = input = ""
    while input != '#'
      input = Readline.readline('> ', true)
      return if input.nil?
      ruby += input.to_s + "\n"
    end
    begin
      eval(ruby, RbshVariables.context)
    rescue Exception => e
      puts e.message
    end
  end
  
end
