# Allows the definition of callbacks on 
# an embedded document.
module EmbeddedDocumentCallbacks
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)

    base.class_eval do 
      alias_method :save_without_callbacks, :save
      alias_method :save, :save_with_callbacks
    end
  end

  module ClassMethods
    def before_create(*methods)
      @embedded_callbacks_on_create ||= []
      methods.each {|m| @embedded_callbacks_on_create << m }
    end

    def embedded_callbacks_on_create
      @embedded_callbacks_on_create || []
    end
  end

  module InstanceMethods
    def save_with_callbacks
      if new_record? && !self.class.embedded_callbacks_on_create.empty?
        self.class.embedded_callbacks_on_create.each do |callback|
          self.send(callback)
        end
      end
      save_without_callbacks
    end
  end
end
