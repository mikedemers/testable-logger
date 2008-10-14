ENV["RAILS_ENV"] = "test"
require 'test/unit'
require 'init'

class TestableLoggerTest < Test::Unit::TestCase
  
  # cases to test:
  # * verify that testable logger is not active in dev and prod

  def test_should_verify_manual_flushing
    logger.error "Four score and seven years ago..."
    assert_logged :error
    logger.flush
    assert_nothing_logged :error
  end
  def test_should_verify_automatic_flushing
    logger.error "our fathers brought forth on this continent..."
    assert_logged :error
    setup
    assert_nothing_logged :error
  end
  
  def test_should_verify_manual_override
    @use_manual_flushing = true
    logger.error "a new nation..."
    assert_logged :error
    setup
    assert_logged :error
    logger.flush
    assert_nothing_logged :error
    @use_manual_flushing = false
  end
  
  def test_should_match_any_log_message
    logger.error "conceived in Liberty..."
    assert_logged
  end
  def test_should_verify_no_messages_logged
    assert_nothing_logged
  end
  
  def test_should_require_warning_message
    logger.warn "and dedicated to the proposition..."
    assert_logged :warn
  end
  def test_should_require_any_log_message
    logger.info "that all men are created equal."
    assert_logged :any
  end
  def test_should_fail_if_warning_logged
    logger.fatal "Now we are engaged in a great civil war..."
    assert_nothing_logged :warn
  end

  def test_should_fail_if_any_message_logged
    assert_nothing_logged :any
  end

  def test_should_match_string
    logger.warn "testing whether that nation..."
    assert_logged :warn, "testing whether that nation..."
  end
  def test_should_not_match_string
    logger.warn "or any nation..."
    assert_nothing_logged :warn, "testing whether"
  end

  def test_should_match_regexp
    logger.warn "so conceived and so dedicated..."
    assert_logged :warn, /conceived.+dedicated/
  end
  def test_should_not_match_regexp
    logger.warn "can long endure."
    assert_nothing_logged :warn, /conceived.+dedicated/
  end

  def test_block_should_find_messages
    logger.warn "But, in a larger sense..."
    logger.warn "we can not dedicate..."
    logger.warn "we can not consecrate..."
    logger.warn "we can not hallow..."
    logger.warn "this ground."
    assert_logged :warn do |messages|
      count_of_things_we_cannot_do = 0
      messages.each do |message|
        count_of_things_we_cannot_do += 1 if message =~ /can not/
      end
      count_of_things_we_cannot_do > 1
    end
  end
  def test_block_should_not_find_messages
    logger.info "government of the people..."
    logger.info "by the people..."
    logger.info "for the people..."
    logger.info "shall not perish from the earth."
    assert_nothing_logged :info do |messages|
      messages.each {|m| return true if m[0..2] == 'abc'}
      false
    end
  end
end
