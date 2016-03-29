class RegularEngine
  def self.make(&block)
    re = new
    re.instance_eval &block
    re.compile
  end

  def compile
    Regexp.new @source
  end

  private

  def initialize
    @source = ''
  end

  def literal(text)
    @source << Regexp.escape(text)
  end
end
