module ChangeLog
  class Config
    include Singleton
    attr_accessor :enabled
 
    def initialize
      # Indicates whether ChangeLog is on or off.
      @enabled = true
    end
  end
end
