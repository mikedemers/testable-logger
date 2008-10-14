require 'logger'

class Test::Unit::TestCase
  # set to +true+ to prevent automatic flushing of log buffers on +setup+
  # mdd: i'm having trouble with this, so i'm just going with a straight instance var
  #attr_accessor :use_manual_flushing
  
  # is there a logger in the house and if so, is it testable?
  def logger_is_testable?
    logger and logger.is_a? TestableLogger
  end
  
  # returns the current logger
  def logger
    @logger ||= (Object.const_defined? :RAILS_DEFAULT_LOGGER) ?
                                          RAILS_DEFAULT_LOGGER :
                                          TestableLogger.new(Logger.new(nil))
  end

  # tests to see if a message was logged at the given level (or :any)
  # since the last #flush.  +match+ can be a String or a Regexp and if
  # provided it will be compared against each message logged at the
  # given level, returning true if it matches and false otherwise.
  # if a block is given, match will be ignored and the block will be called
  # with an array of message strings as it's only parameter.  the block should
  # return true for a match and false otherwise.
  def assert_logged(level=:any, match=nil, &block)
    return false unless logger_is_testable?
    
    assert find_buffered_messages(level, match, &block),
           "No logged messages%s%s." % [ (match.nil?) ? '' : ' matched ',
                                         case match
                                         when String ; match
                                         when Regexp ; match.inspect
                                         else ; '' ; end  ]
  end
  
  # with no +match+ parameter, verifies that nothing was logged at the given
  # log level.  if +match+ is given, verifies that nothing was logged at the
  # given level that matches the Regexp (if match is a Regexp) or is equal to
  # the String (if match is a string).
  # if a block is given, match will be ignored and the block will be called
  # with an array of message strings as it's only parameter.  the block should
  # return true for a match and false otherwise.
  def assert_nothing_logged(level=:any, match=nil, &block)
    return false unless logger_is_testable?
    assert ! find_buffered_messages(level, match, &block),
             "Found logged messages%s%s." % [ (match.nil?) ? '' : ' matching ',
                                              case match
                                              when String ; match
                                              when Regexp ; match.inspect
                                              else ; '' ; end  ]
  end
  
  # return true if a buffered log message at the given level matches the
  # given criteria
  def find_buffered_messages(level, match, &block)
    if logger and messages = logger.messages_for(level)
      if block_given?
        return yield(messages)
      else
        case match
        when nil    ;   return true
        when Regexp ;   messages.each {|m| return true if match =~ m}
        when String ;   messages.each {|m| return true if match == m}
        else        ;   raise "Unsupported match type: #{match.class}"
        end
      end
    end
    false
  end

  # insert a flush command into every call to #setup unless overridden by
  # the instance variable @use_manual_flushing
  def setup_with_testable_logger(*args)
    setup_without_testable_logger(*args) rescue true
    logger.flush unless @use_manual_flushing
  end
  
  # make our proxy setup the default setup, triggering the rails
  # fixture setup aliasing logic
  alias_method  :setup, :setup_with_testable_logger
  
  # save a reference to the setup that was just rewritten to call the
  # fixtures setup code
  alias_method  :setup_from_fixtures_method_added, :setup
  
private
  
  # save a reference to the #method_added method used by rails
  alias_method :method_added_before_testable_logger, :method_added     rescue true
  
  def self.method_added(m)
    if (m == :setup) && (! method_defined?(:setup_without_testable_logger))
      # save a reference to the newly defined setup method
      alias_method :setup_without_testable_logger,  :setup
      
      # restore rails' setup method containing the fixtures logic
      alias_method :setup, :setup_from_fixtures_method_added
    else
      # if we're not doing anything with it, pass along the method creation event
      self.send(:method_added_before_testable_logger, m) if method_defined? :method_added_before_testable_logger
    end
  end
end
