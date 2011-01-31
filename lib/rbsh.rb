require 'readline'
require 'etc'
require 'lib/rbsh_helper'

class Rbsh
  def initialize
    @home = Etc.getpwuid.dir
    @running ||= true
    @pwd ||= ENV['PWD']
    @previous_dir ||= @pwd
    
    # read ~/.rbshrc and/or ~/.rbshrc.rb
    begin
      load @home + '/.rbshrc'
    rescue LoadError => e
    end
    begin
      load @home + '/.rbshrc.rb'
    rescue LoadError => e
    end
    nil
  end
  
  def main
    while @running
      hostname = `hostname`.chomp.split('.').first
      @pwd = @pwd.gsub(@home, '~')
      @prompt = "#{ENV['USER']}@#{hostname}:#{@pwd}$ "
      
      @command = Readline.readline(@prompt, true)
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
            output = send(:cd, split_com[-1])
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
    @command = ""
    input = @command
    while input != '#'
      input = Readline.readline('> ', true)
      return if input.nil?
      @command += input.to_s + "\n"
    end
    begin
      eval(@command)
    rescue Exception => e
      puts e.message
    end
  end
  
  def system_call
    return if @system_command
    exec = @command
    sys_output = system "#{exec}"
    @system_command = true
    puts "No command or method found: #{exec}" unless sys_output
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
      old_prev_dir = @previous_dir
      if dir.nil?
        @previous_dir = Dir.pwd
        Dir.chdir(@home)
      else
        dir = dir.first.gsub('~', @home)
        dir = @previous_dir if dir == '-'
        @previous_dir = Dir.pwd
        Dir.chdir(dir)
      end
    rescue Errno::ENOENT => e
      puts "No such directory: #{dir}"
      @previous_dir = old_prev_dir
    end
    @pwd = Dir.pwd
    return nil
  end
  
  def method_missing(sym, *args, &block)
    system_call
  end
  
end
