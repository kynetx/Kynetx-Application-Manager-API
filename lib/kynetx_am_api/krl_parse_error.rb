class KRLParseError < StandardError
  
  attr_reader :parse_errors

  def initialize(msg, errors)
    if errors.class == Array
      @parse_errors = errors
    else
      @parse_errors = errors.to_s
    end

    super(msg)
  end

end
