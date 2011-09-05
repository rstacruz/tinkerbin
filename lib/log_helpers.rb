module LogHelpers
  def color(str, col=0)
    "\033[0;#{col}m#{str}\033[0;m"
  end

  def err(message)
    if message.is_a?(StandardError)
      err "#{message.class}: #{message.message}"
      message.backtrace.each { |line| err "  " + line }
    else
      puts "#{color "ERR:", 31} #{message}"
    end
  end

  def warn(message)
    puts "#{color "   *", 36} #{message}"
  end

  def status(message, prefix='*', col=36)
    puts "%-5s  %s" % [ color(prefix, col), message ]
  end
end
