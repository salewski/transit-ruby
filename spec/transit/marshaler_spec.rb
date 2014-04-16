require 'spec_helper'

module Transit
  describe Marshaler do
    let(:marshaler) { TransitMarshaler.new }

    it 'marshals 1 at top' do
      marshaler.marshal_top(1)
      assert { marshaler.value == 1 }
    end

    it 'escapes a string' do
      marshaler.marshal_top("~this")
      assert { marshaler.value == "~~this" }
    end

    it 'marshals 1 in an array' do
      marshaler.marshal_top([1])
      assert { marshaler.value == [1] }
    end

    it 'marshals 1 in a nested array' do
      marshaler.marshal_top([[1]])
      assert { marshaler.value == [[1]] }
    end

    it 'marshals a map' do
      marshaler.marshal_top({"a" => 1})
      assert { marshaler.value == {"a" => 1} }
    end

    it 'marshals a nested map' do
      marshaler.marshal_top({"a" => {"b" => 1}})
      assert { marshaler.value == {"a" => {"b" => 1}} }
    end

    it 'marshals a big mess' do
      input   = {"~a" => [1, {:b => [2,3]}, 4]}
      output  = {"~~a" => [1, {"~:b" => [2,3]}, 4]}
      marshaler.marshal_top(input)
      assert { marshaler.value == output }
    end

    it 'marshals a top-level scalar in a map when requested' do
      marshaler =  TransitMarshaler.new(:quote_scalars => true)
      marshaler.marshal_top(1)
      assert { marshaler.value == {"~#'"=>1} }
    end

    it 'marshals Time as a string for json' do
      t = Time.now
      marshaler =  TransitMarshaler.new(:quote_scalars => false, :prefer_strings => true)
      marshaler.marshal_top(t)
      assert { marshaler.value == "~t#{t.utc.iso8601(3)}" }
    end

    it 'marshals DateTime as a string for json' do
      t = DateTime.now
      marshaler =  TransitMarshaler.new(:quote_scalars => false, :prefer_strings => true)
      marshaler.marshal_top(t)
      assert { marshaler.value == "~t#{t.new_offset(0).iso8601(3)}" }
    end

    it 'marshals a Date as a string for json' do
      t = Date.new(2014,1,2)
      marshaler =  TransitMarshaler.new(:quote_scalars => false, :prefer_strings => true)
      marshaler.marshal_top(t)
      assert { marshaler.value == "~t2014-01-02T00:00:00.000Z" }
    end

    it 'marshals Time as a map for msgpack' do
      t = Time.now
      marshaler =  TransitMarshaler.new(:quote_scalars => false, :prefer_strings => false)
      marshaler.marshal_top(t)
      assert { marshaler.value == {"~#t" => Util.time_to_millis(t)} }
    end

    it 'marshals DateTime as a map for msgpack' do
      dt = DateTime.now
      marshaler =  TransitMarshaler.new(:quote_scalars => false, :prefer_strings => false)
      marshaler.marshal_top(dt)
      assert { marshaler.value == {"~#t" => Util.date_time_to_millis(dt)} }
    end

    it 'marshals a Date as a map for msgpack' do
      d = Date.new(2014,1,2)
      marshaler =  TransitMarshaler.new(:quote_scalars => false, :prefer_strings => false)
      marshaler.marshal_top(d)
      assert { marshaler.value == {"~#t" => Util.date_to_millis(d) } }
    end
  end
end
