class RegularEngine
  def self.make(&block)
    evaluate(&block).compile
  end

  def compile
    Regexp.new @source
  end

  def to_s
    @source
  end

  protected

  def self.evaluate(&block)
    re = new
    re.instance_eval &block
    re
  end

  private

  def initialize
    @source = ''
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
end
