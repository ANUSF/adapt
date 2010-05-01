module LazyEnumerable
  include Enumerable

  def map(&block)
    raise 'No block given.' unless block_given?
    Generator.new do |yielder|
      self.each do |value|
        yielder.yield(block.call(value))
      end
    end
  end

  def select(&block)
    raise 'No block given.' unless block_given?
    Generator.new do |yielder|
      self.each do |value|
        yielder.yield(value) if block.call(value)
      end
    end
  end

  def take_while(&block)
    raise 'No block given.' unless block_given?
    Generator.new do |yielder|
      self.each do |value|
        if block.call(value)
          yielder.yield(value)
        else
          break
        end
      end
    end
  end

  def accumulate(init, &block)
    raise 'No block given.' unless block_given?
    Generator.new do |yielder|
      acc = init
      self.each do |value|
        acc = block.call(acc, value)
        yielder.yield(acc)
      end
    end
  end

  def with_accumulated(init, &block)
    raise 'No block given.' unless block_given?
    accumulate([nil, init]) { |acc, val| [val, block.call(acc[1], val)] }
  end

  def drop_while(&block)
    raise 'No block given.' unless block_given?
    with_accumulated(true) { |dropping, value|
      dropping && block.call(value)
    }.select { |val, dropping| not dropping }.map { |val, x| val }
  end

  def with_index
    with_accumulated(-1) { |acc, value| acc + 1 }
  end

  def take(n)
    with_index.take_while { |a, i| i < n }.map { |a, i| a }
  end

  def drop(n)
    with_index.drop_while { |a, i| i < n }.map { |a, i| a }
  end

  class Yielder
    def initialize(&block)
      raise 'No block given.' unless block_given?
      @block = block
      freeze
    end

    def yield(x)
      @block.call(x)
    end
  end
  
  class Generator
    include LazyEnumerable
      
    def initialize(&code)
      raise 'No block given.' unless block_given?
      @code = code
      freeze
    end

    def each(&block)
      if block_given?
        @code.call(Yielder.new(&block))
      else
        self
      end
    end
  end

  class Stream < Generator
    def initialize(first, &succ)
      raise 'No block given.' unless block_given?
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
