describe Solargraph::Source::Chain do
  let(:api_map) { Solargraph::ApiMap.new }

  it "infers methods returning self from CoreFills" do
    source = Solargraph::Source.load_string(%(
      # @type [Array<String>]
      x = []
      x.select
    ))
    api_map.virtualize source
    fragment = source.fragment_at(3, 9)
    pin = api_map.define(fragment).first
    expect(pin.return_complex_type.tag).to eq('Array<String>')
  end

  it "infers methods returning subtypes from CoreFills" do
    source = Solargraph::Source.load_string(%(
      # @type [Array<String>]
      x = []
      x.first
    ))
    api_map.virtualize source
    fragment = source.fragment_at(3, 9)
    pin = api_map.define(fragment).first
    expect(pin.return_complex_type.tag).to eq('String')
  end
end