require 'readline'
require 'etc'
require './lib/rbsh_helper'

class Rbsh
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
    begin
      eval(File.new(@HOME + '/.rbshrc').read)
    rescue Errno::ENOENT => e
    rescue SyntaxError => e
      RbshHelper.rbshrc_syntax_error
    end
    begin
      eval(File.new(@HOME + '/.rbshrc.rb').read)
    rescue Errno::ENOENT => e
    rescue SyntaxError => e
      RbshHelper.rbshrc_syntax_error
    end
    @SHELL = File.expand_path $0
    instance_variables.each do |var|
      ENV[var[1..-1]] = instance_variable_get(var)
    end
    true
  end
  
  def self.alias(sym, cmd)
    define_method sym do
      system cmd
      return nil
    end 
  end
  
  def main
    while @running
      hostname = `hostname`.chomp.split('.').first
      #@PWD = @PWD.gsub(@HOME, '~')
      
      @command = Readline.readline(@PS1, true)
      if @command.nil?
        print "\n"
        exit
      elsif @command.strip == '#'
        multi_line
      else
        @system_command = false
      
        if @command == "main"
          output = method_missing(@command)
        else
          # special case for cd
          split_com = @command.split(/(\s+|\()/, 2)
          if split_com.first == "cd"
            output = cd(split_com[-1])
          else
            #output = @arguments.nil? ? send(@command) : send(@command, @arguments)
            begin
              output = eval(@command)
              output = output.inspect unless output.nil?
            rescue NameError => e
              system_call
            rescue SyntaxError => e
              system_call
            rescue ArgumentError => e
              system_call
            end
          end
        end

        if !@system_command && output && !output.empty?
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
      eval(ruby)
    rescue Exception => e
      puts e.message
    end
  end
  
  def system_call
    return if @system_command
    sys_output = system "#{@command}"
    @system_command = true
    puts "No command or method found: #{@command}" unless sys_output
    return sys_output
  end
  
  def exit(*args)
    @running = false
  end
  
  def quit(*args)
    exit
  end
  
  def cd(dir=nil)
    begin
      old_prev_dir = @OLD_PWD
      if dir.nil?
        @OLD_PWD = Dir.pwd
        Dir.chdir(@HOME)
      else
        dir = dir.first.gsub('~', @HOME)
        dir = @OLD_PWD if dir == '-'
        @OLD_PWD = Dir.pwd
        Dir.chdir(dir)
      end
    rescue Errno::ENOENT => e
      puts "No such directory: #{dir}"
      @OLD_PWD = old_prev_dir
    end
    @PWD = Dir.pwd
    return nil
  end
  
  def method_missing(sym, *args, &block)
    if @running
      system_call
    else
      RbshHelper.rbshrc_syntax_error
    end
  end
  
end
