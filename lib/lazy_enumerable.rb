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

  def with_index
    Generator.new do |yielder|
      i = 0
      self.each do |value|
        yielder.yield([value, i])
        i += 1
      end
    end
  end

  def take(n)
    Generator.new do |yielder|
      i = 0
      self.each do |value|
        if i < n
          yielder.yield(value)
          i += 1
        else
          return
        end
      end
    end
  end

  def drop(n)
    Generator.new do |yielder|
      i = 0
      self.each do |value|
        if i >= n
          yielder.yield(value)
        else
          i += 1
        end
      end
    end
  end

  def fold(init, &block)
    Generator.new do |yielder|
      acc = init
      self.each do |value|
        acc = block.call(acc, value)
        yielder.yield(acc)
      end
    end
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
