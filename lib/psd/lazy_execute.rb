class PSD
  # Used for lazily executing methods on demand
  class LazyExecute
    def initialize(obj, file)
      @obj = obj
      @file = file

      @start_pos = @file.tell
      @loaded = false
      @load_method = nil
      @load_args = []

      PSD.logger.debug "Marked #{@obj.class.name} at position #{@start_pos} for lazy execution"
    end

    def now(method, *args, &block)
      PSD.logger.debug "Executing #{@obj.class.name}##{method} now"
      @obj.send(method, *args, &block)
      return self
    end

    def later(method, *args)
      @load_method = method
      @load_args = args
      return self
    end

    def has_loaded?
      @loaded
    end

    def method_missing(method, *args, &block)
      load! unless has_loaded?
      @obj.send(method, *args, &block)
    end

    private

    def load!
      PSD.logger.debug "Lazily executing #{@obj.class.name}##{@load_method}"
      orig_pos = @file.tell
      @file.seek @start_pos

      @obj.send(@load_method, *@load_args)

      @file.seek orig_pos
      @loaded = true
    end
  end
end