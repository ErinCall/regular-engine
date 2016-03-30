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

  it 'has a helper for +' do
    re = RegularEngine.make do
      one_or_more { literal 'hey' }
    end

    expect(re).to eq /(?:hey){1,}/

    expect('heyheyhey' =~ re).to eq(0)
    expect('hey' =~ re).to eq(0)
    expect('h' =~ re).to be_nil
  end

  it 'has a helper for *' do
    re = RegularEngine.make do
      zero_or_more { literal 'hey' }
    end

    expect(re).to eq /(?:hey){0,}/

    expect('heyheyhey' =~ re).to eq(0)
    expect('hey' =~ re).to eq(0)
    expect('h' =~ re).to eq(0)
  end

  it 'has a helper for ?' do
    re = RegularEngine.make do
      maybe { literal 'hey' }
    end

    expect(re).to eq /(?:hey){0,1}/
  end

  it 'has a helper for \w' do
    re = RegularEngine.make { word_character }

    expect(re).to eq /\w/
  end

  it 'has a helper for \d' do
    re = RegularEngine.make { number }

    expect(re).to eq /\d/
  end

  it 'has a helper for \s' do
    re = RegularEngine.make { whitespace }

    expect(re).to eq /\s/
  end

  describe 'any_of' do
    it 'accepts a list of strings' do
      re = RegularEngine.make { any_of %w{a b c} }

      expect(re).to eq /[abc]/
    end

    it 'accepts a range of strings' do
      re = RegularEngine.make { any_of 'a'..'c' }

      expect(re).to eq /[abc]/
    end

    it 'treats dashes as literal dashes in the character class' do
      re = RegularEngine.make { any_of ['a', '-', 'c'] }

      expect(re).to eq /[a\-c]/
    end

    it 'accepts a block when given no arguments' do
      re = RegularEngine.make do
        any_of do
          literal 'abc'
          literal 'def'
        end
      end

      expect(re).to eq /(?:abc|def)/
    end
  end
end
