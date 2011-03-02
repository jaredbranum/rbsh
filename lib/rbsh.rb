require 'readline'
require './lib/rbsh_helper'
require './lib/rbsh_variables'
require './lib/shell'

class Rbsh
  
  def initialize
    @shell ||= Shell.new
    set_environment_variables
    if File.exists?(ENV['HOME'] + '/.rbsh_history')
      File.open(ENV['HOME'] + '/.rbsh_history', 'r') do |f|
        while line = f.gets ; Readline::HISTORY.push(line.chomp) ; end
      end
    end
  end

  def self.alias(*args)
    Shell.alias(*args)
  end
  
  def main(argv=[])
    while RbshVariables.running?
      if argv.empty?
        command = Readline.readline(RbshHelper.parse_ps1(@shell.PS1.to_s), true)
        if command
          File.open(ENV['HOME'] + '/.rbsh_history', 'a') { |f| f.write(command + "\n") }
        end
        execute_command(command)
      else
        argv.each do |cmd|
          command = cmd
          execute_command(command)
        end
        argv=[]
      end
    end
  end
  
  def execute_command(command)
    if command.nil?
      print "\n"
      exit
    elsif command.strip == '#'
      multi_line
    else
      RbshVariables.system_command = false

      # special case for builtins
      split_com = command.lstrip.split(/\s+/, 2)
      return if split_com.first.nil? || split_com.first.empty?
      if @shell.respond_to?(split_com.first)
        begin
          output = split_com.length == 1 ? @shell.send(split_com.first.to_sym) : @shell.send(split_com.first.to_sym, split_com.last)
        rescue Exception => e
          raise e if e.class == SystemExit # don't stop exit method
          output = nil
          puts "Exception: #{e.message} (#{e.class})"
        end
      else
        begin
          output = eval(command, RbshVariables.context)
        rescue NameError, SyntaxError, ArgumentError, NoMethodError => e
          @shell.system_call(command)
        end
      end

      if !RbshVariables.system_command? && output
        output = output.inspect
        puts '=> ' + output
      end
    end
    set_environment_variables
  end
  
  def set_environment_variables
    @shell.instance_variables.each do |var|
      ENV[var[1..-1]] = @shell.instance_variable_get(var).to_s
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
