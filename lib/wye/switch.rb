module Wye
  class Switch
    attr_reader :base_class

    def initialize(base_class)
      @base_class = base_class
      @thread_to_class_to_alternate = {}
      @mutex = Mutex.new
    end

    def current_alternate(klass, cta = nil)
      return nil unless klass

      cta ||= class_to_alternate
      alternate = cta[klass]

      return alternate.first unless alternate.nil? || alternate.empty?
      return nil if klass == base_class
      current_alternate(klass.superclass, cta)
    end

    def on(klass, alternate)
      class_to_alternate[klass] ||= []
      class_to_alternate[klass].unshift(alternate)
      yield
    ensure
      class_to_alternate[klass].shift
      clean_up_after_dead_threads
    end

    private

    def class_to_alternate(thread = Thread.current)
      cta = @thread_to_class_to_alternate[thread] ||= {}
      cta.empty? ? (thread == Thread.main ? cta : class_to_alternate(Thread.main)) : cta
    end

    def clean_up_after_dead_threads
      @mutex.synchronize { @thread_to_class_to_alternate.delete_if { |thread| !thread.alive? } }
    end

  end
end
