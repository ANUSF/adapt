module LazyEnumerable
  include Enumerable

  def map(&block)
    Generator.new do |yielder|
      self.each do |value|
        yielder.yield(block.call(value))
      end
    end
  end

  class Yielder
    def initialize(&block)
      @block = block
    end

    def yield(x)
      @block.call(x)
    end
  end
  
  class Generator
    include LazyEnumerable
      
    def initialize(&code)
      @code = code
    end

    def each(&block)
      @code.call(Yielder.new(&block))
    end
  end

  class Stream < Generator
    def initialize(first, &succ)
      super() do |yielder|
        this = first
        while this
          yielder.yield this
          this = succ.call(this)
        end
      end
    end
  end  
end
