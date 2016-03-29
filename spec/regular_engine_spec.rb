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
end
