require 'regular_engine'

describe RegularEngine do
  it 'makes a regular expression' do
    re = RegularEngine.make {}

    expect(re).to be_a(Regexp)
  end

  describe 'literal' do
    it "matches regular ol' letters" do
      re = RegularEngine.make do
        literal 'abc'
      end

      expect(re).to eq /abc/
    end

    it 'escapes metacharacters' do
      re = RegularEngine.make do
        literal '.'
      end

      expect(re).to eq /\./
    end

    it 'passes unicode characters through unmolested' do
      emojis = "\u{1F469}\u{200D}\u{2764}\u{FE0F}\u{200D}\u{1f469}"
      re = RegularEngine.make { literal emojis }
      expect(re).to eq Regexp.new(emojis)
    end
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

  it 'has a helper for \W' do
    re = RegularEngine.make { non_word_character }

    expect(re).to eq /\W/
  end

  it 'has a helper for \d' do
    re = RegularEngine.make { number }

    expect(re).to eq /\d/
  end

  it 'has a helper for \D' do
    re = RegularEngine.make { non_number }

    expect(re).to eq /\D/
  end

  it 'has a helper for \s' do
    re = RegularEngine.make { whitespace }

    expect(re).to eq /\s/
  end

  it 'has a helper for \S' do
    re = RegularEngine.make { non_whitespace }

    expect(re).to eq /\S/
  end

  it 'has a helper for ^' do
    re = RegularEngine.make {
      line_start
      literal 'a'
    }

    expect(re).to eq /^a/
  end

  it 'has a helper for $' do
    re = RegularEngine.make {
      literal 'a'
      line_end
    }

    expect(re).to eq /a$/
  end

  it 'has a helper for \A' do
    re = RegularEngine.make {
      text_start
      literal 'a'
    }

    expect(re).to eq /\Aa/
  end

  it 'has a helper for \z' do
    re = RegularEngine.make {
      literal 'a'
      text_end
    }

    expect(re).to eq /a\z/
  end

  it 'has a helper for \Z' do
    re = RegularEngine.make {
      literal 'a'
      file_end
    }

    expect(re).to eq /a\Z/
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

    it 'treats range metacharacters as literals' do
      re = RegularEngine.make { any_of %w{^ a - c} }

      expect(re).to eq /[\^a\-c]/
      # just verify that the escaping is correct
      expect('^' =~ re).to eq 0
      expect('-' =~ re).to eq 0
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

  describe 'none_of' do
    it 'accepts and negates a list of strings' do
      re = RegularEngine.make { none_of %w{a b c} }

      expect(re).to eq /[^abc]/
    end

    it 'accepts a range of strings' do
      re = RegularEngine.make { none_of 'a'..'c' }

      expect(re).to eq /[^abc]/
    end

    it 'treats range metacharacters as literals' do
      re = RegularEngine.make { none_of %w{^ a - c} }

      expect(re).to eq /[^\^a\-c]/
      # just verify that the escaping is correct
      expect('^' =~ re).to eq nil
      # if the dash isn't escaped properly, the regex will refuse to match a
      # 'b', since it'll be part of the [a-c] range.
      expect('b' =~ re).to eq 0
    end

    it 'accepts a block when given no arguments' do
      re = RegularEngine.make do
        none_of do
          literal 'abc'
          literal 'def'
        end
      end

      expect(re).to eq /(?:(?!abc)(?!def))/
      # without anchors, the behavior of none_of is a little counterintuitive.
      # here it's equal to 1 because it's matching starting at the "b"--"bc"
      # is something other than "abc", after all. Using a start-of-string
      # anchor, or something like that, would make this less surprising, but
      # start-of-string isn't implemented as of this writing :)
      expect('abc' =~ re).to eq 1
    end
  end
end
