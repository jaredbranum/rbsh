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
  
  def main
    while RbshVariables.running?
      hostname = `hostname`.chomp.split('.').first
      #@PWD = @PWD.gsub(@HOME, '~')
      
      RbshVariables.command = Readline.readline(RbshHelper.parse_ps1(@shell.PS1), true)
      if RbshVariables.command.nil?
        print "\n"
        exit
      elsif RbshVariables.command.strip == '#'
        multi_line
      else
        RbshVariables.system_command = false
      
        if RbshVariables.command == "main"
          output = method_missing(@command)
        else
          # special case for builtins
          split_com = RbshVariables.command.split(/\s+/, 2)
          if @shell.respond_to?(split_com.first)
            output = split_com.length == 1 ? @shell.send(split_com.first.to_sym) : @shell.send(split_com.first.to_sym, split_com.last)
          else
            #output = @arguments.nil? ? send(@command) : send(@command, @arguments)
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
        end

        if !RbshVariables.system_command? && output && !output.empty?
          puts '=> ' + output
        end
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
