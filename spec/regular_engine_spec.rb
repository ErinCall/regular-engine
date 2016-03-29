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
end
