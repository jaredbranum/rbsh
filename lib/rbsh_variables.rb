class RbshVariables
  class << self;
    attr_accessor :context
    attr_writer   :system_command

    def system_command?
      !!@system_command
    end
  end
end
