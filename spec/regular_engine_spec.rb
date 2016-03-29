require 'regular_engine'

describe RegularEngine do
  it 'makes a regular expression' do
    re = RegularEngine.make {}

    expect(re).to be_a(Regexp)
  end

  it 'can make a regex that matches a literal string' do
    re = RegularEngine.make do
      literal 'abc'
    end

    expect(re).to eq /abc/
  end

  it 'escapes metacharacters in literals' do
    re = RegularEngine.make do
      literal '.'
    end

    expect(re).to eq /\./
  end

  it 'makes any-char regexps' do
    re = RegularEngine.make do
      any_char
    end

    expect(re).to eq /./
  end

  it 'makes exactly-n regexps' do
    re = RegularEngine.make do
      exactly(4) {
        literal 'a'
      }
    end

    expect(re).to eq /(?:a){4}/
  end

  it 'makes at-least-n regexps' do
    re = RegularEngine.make do
      at_least(4) { literal 'a' }
    end

    expect(re).to eq /(?:a){4,}/
    expect('aaaaaaaaa' =~ re).to eq 0
  end

  it 'makes at-most-n regexps' do
    re = RegularEngine.make do
      at_most(4) { literal 'a' }
    end

    expect(re).to eq /(?:a){,4}/
    expect('a' =~ re).to eq 0
  end

  describe 'from n to m regexp' do
    it 'accepts a start and end' do
      re = RegularEngine.make do
        between(4, 6) { literal 'a' }
      end

      expect(re).to eq /(?:a){4,6}/
    end

    it 'accepts a range' do
      re = RegularEngine.make do
        between(4..6) { literal 'a' }
      end

      expect(re).to eq /(?:a){4,6}/
    end

    it 'gives a useful error message when given one number' do
      expect(Proc.new {
        re = RegularEngine.make do
          between(4) { literal 'a' }
        end
      }).to raise_error(ArgumentError)
    end
  end
end
