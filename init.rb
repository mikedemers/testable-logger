
# make sure this only takes effect in the TEST environment
if ENV["RAILS_ENV"] == "test"
  require "logger"
  require "testable_logger"

  # insert the TestableLogger as a proxy in front of the actual logger
  # objects.  this feels kind of hack-ish to me, so if someone knows of
  # a cleaner way to do this, please let me know.
  # <mike@teytek.com> (2006.07.01)
  Object.const_set :RAILS_DEFAULT_LOGGER,
                   TestableLogger.new(
                     (Object.const_defined? :RAILS_DEFAULT_LOGGER) ?
                        Object.class_eval { remove_const :RAILS_DEFAULT_LOGGER } :
                        Logger.new(nil))
  ActionController::Base.logger = RAILS_DEFAULT_LOGGER if Object.const_defined? :ActionController
  ActiveRecord::Base.logger     = RAILS_DEFAULT_LOGGER if Object.const_defined? :ActiveRecord
  ActionMailer::Base.logger     = RAILS_DEFAULT_LOGGER if Object.const_defined? :ActionMailer
  
  require "testable_logger_test_case"
end
