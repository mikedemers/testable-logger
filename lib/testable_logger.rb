#
# acts as a proxy in front of the normal Logger object, storing the messages
# that are logged during a test and making them available for assertions.
#
class TestableLogger
  attr_accessor :levels
  def flush
    @buffer = {}
  end
  def messages_for(level)
    if level == :any
      @buffer.values.inject {|all,msgs| msgs.each {|m| all << m}; all}
    else
      @buffer[level]
    end
  end
private
  def initialize(logger=nil)
    @logger = logger
    @buffer = {}
    @levels = [ :fatal, :info, :error, :warn, :debug ]
  end
  def method_missing(m, *p)
    (@buffer[m] ||= []) << p.first if levels.flatten.include? m
    @logger.send(m, *p) if @logger
  end
end
