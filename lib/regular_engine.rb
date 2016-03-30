class RegularEngine
  def self.make(&block)
    evaluate(&block).compile
  end

  def compile
    Regexp.new to_s
  end

  def to_s
    join ''
  end

  def join(delimiter)
    @source.join(delimiter)
  end

  protected

  def self.evaluate(&block)
    re = new
    re.instance_eval &block
    re
  end

  private

  def initialize
    @source = []
  end

  def literal(text)
    @source << Regexp.escape(text)
  end

  def any_char
    @source << '.'
  end

  def exactly(n, &block)
    subexpression = self.class.evaluate &block
    @source << "(?:#{subexpression.to_s}){#{n}}"
  end

  def at_least(n, &block)
    subexpression = self.class.evaluate &block
    @source << "(?:#{subexpression.to_s}){#{n},}"
  end

  def at_most(n, &block)
    subexpression = self.class.evaluate &block
    @source << "(?:#{subexpression.to_s}){,#{n}}"
  end

  def between(n, m=nil, &block)
    if m.nil? && n.instance_of?(Range)
      m = n.end
      n = n.begin
    elsif m.nil?
      # ehhhh, this is sorta brittle...
      raise ArgumentError.new("wrong number of arguments (given 1, expected 2)")
    end

    subexpression = self.class.evaluate &block
    @source << "(?:#{subexpression.to_s}){#{n},#{m}}"
  end

  def one_or_more(&block)
    at_least(1, &block)
  end

  def zero_or_more(&block)
    at_least(0, &block)
  end

  def maybe(&block)
    between(0, 1, &block)
  end

  def word_character
    @source << '\w'
  end

  def number
    @source << '\d'
  end

  def whitespace
    @source << '\s'
  end

  def any_of(chars=nil, &block)
    if chars.nil? && block_given?
      subexpression = self.class.evaluate &block
      @source << "(?:#{subexpression.join('|')})"
    elsif chars.respond_to? :map
      character_class = chars.map(&Regexp.method(:escape)).join ''
      @source << "[#{character_class}]"
    else
      raise ArgumentError.new("wrong number of arguments (given 0, expected 1)")
    end
  end
end
