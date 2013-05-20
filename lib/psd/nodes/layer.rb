class PSD::Node
  class Layer < PSD::Node
    include PSD::Node::LockToOrigin

    PROPERTIES = [:name, :left, :right, :top, :bottom, :height, :width]

    def initialize(layer)
      @layer = layer
      layer.node = self
      @children = []
    end

    PROPERTIES.each do |meth|
      define_method meth do
        @layer.send(meth)
      end

      define_method "#{meth}=" do |val|
        @layer.send("#{meth}=", val)
      end
    end

    def translate(x=0, y=0)
      @layer.translate x, y
    end

    def scale_path_components(xr, yr)
      @layer.scale_path_components(xr, yr)
    end

    def hide!
      # TODO actually mess with the blend modes instead of
      # just putting things way off canvas
      return if @hidden_by_kelly
      translate(100000, 10000)
      @hidden_by_kelly = true
    end

    def show!
      if @hidden_by_kelly
        translate(-100000, -10000)
        @hidden_by_kelly = false
      end
    end

    def to_hash
      hash = {}
      PROPERTIES.each do |p|
        hash[p] = self.send(p)
      end

      return hash
    end

    def document_dimensions
      @parent.document_dimensions
    end

    def method_missing(meth, *args, &block)
      if @layer.respond_to?(meth)
        @layer.send(meth)
      else
        super
      end
    end
  end
end