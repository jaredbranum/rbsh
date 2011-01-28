require 'readline'
require 'etc'

class Rbsh
  def initialize
    @home = Etc.getpwuid.dir
    @running ||= true
    @pwd ||= ENV['PWD']
    @previous_dir ||= @pwd
    
    # read ~/.rbshrc.rb
    begin
      load @home + '/.rbshrc.rb'
    rescue LoadError => e # no .rbshrc.rb file found
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
      else      
        #arr = arr.chomp.split(' ')
        # begin
        #   @command = arr.first
        #   if @command
        #     @command = @command.to_sym
        #   else 
        #     next
        #   end
        # rescue ArgumentError => e
        #   puts 'ERROR ERROR ERROR'
        # end
        # if arr[1..-1].empty?
        #   @arguments = nil
        # else
        #   @arguments = arr[1..-1]
        # end
      
        @system_command = false
      
        if @command == "main"
          output = method_missing(@command)
        else
          # special case for cd
          split_com = @command.split(/[ |\(]/, 2)
          if split_com.first == "cd"
            output = send(:cd, split_com[1])
          else
            #output = @arguments.nil? ? send(@command) : send(@command, @arguments)
            begin
              output = eval(@command)
              output = output.inspect unless output.nil?
            rescue NameError => e
              method_missing(@command)
            rescue SyntaxError => e
              method_missing(@command)
            end
          end
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
    return if @system_command
    exec = @command #.to_s
    # if args && !args.empty?
    #   args.each { |arg| exec += " #{arg.to_s}" }
    # end
    sys_output = system "#{exec}"
    @system_command = true
    puts "No command or method found: #{exec}" unless sys_output
    return sys_output
  end
  
end
