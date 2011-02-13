class RbshVariables
  class << self;
    attr_accessor :command
    attr_accessor :context
    attr_writer   :running
    attr_writer   :system_command

    def running?
      !!@running
    end

    def system_command?
      !!@system_command
    end
  end
end
