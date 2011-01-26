require 'readline'
require 'etc'

class Rubbish
  def initialize
    @home = Etc.getpwuid.dir
    @running ||= true
    @pwd ||= ENV['PWD']
    @previous_dir ||= @pwd
    
    # read ~/.rubbishrc.rb
    begin
      load @home + '/.rubbishrc.rb'
    rescue LoadError => e # no .rubbishrc.rb file found
    end
    nil
  end
  
  def main
    while @running
      hostname = `hostname`.chomp.split('.').first
      @pwd = @pwd.gsub(@home, '~')
      @prompt = "#{ENV['USER']}@#{hostname}:#{@pwd}$ "
      
      arr = Readline.readline(@prompt, true)
      if arr.nil?
        print "\n"
        exit
      else      
        arr = arr.chomp.split(' ')
        begin
          @command = arr.first
          if @command
            @command = @command.to_sym
          else 
            next
          end
        rescue ArgumentError => e
          puts 'ERROR ERROR ERROR'
        end
        if arr[1..-1].empty?
          @arguments = nil
        else
          @arguments = arr[1..-1]
        end
      
        @system_command = false
      
        if @command == :main
          output = method_missing(@command, @arguments)
        else
          output = @arguments.nil? ? send(@command) : send(@command, @arguments)
          output = output.inspect unless output.nil?
        end

        if !@system_command && output && !output.empty?
          puts '=> ' + output
        end
      end
    end
  end
  
  def exit(*args)
    @running = false
  end
  
  def cd(dir)
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
    @system_command = true
    exec = sym.to_s
    if args && !args.empty?
      args.each { |arg| exec += " #{arg.to_s}" }
    end
    sys_output = system "#{exec}"
    puts "No command or method found: #{exec}" unless sys_output
    return sys_output
  end
  
end