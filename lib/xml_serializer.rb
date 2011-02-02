module MongoMapper
  module Plugins
    module Serialization

        class XmlSerializer #:nodoc:
          attr_reader :options

          def initialize(record, options = {})
            @record, @options = record, options.dup
          end

          def builder
            @builder ||= begin
              options[:indent] ||= 2
              builder = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

              unless options[:skip_instruct]
                builder.instruct!
                options[:skip_instruct] = true
              end

              builder
            end
          end

          def root
            root = (options[:root] || @record.class.to_s.underscore).to_s
            dasherize? ? root.dasherize : root
          end

          def dasherize?
            !options.has_key?(:dasherize) || options[:dasherize]
          end


          # To replicate the behavior in ActiveRecord#attributes,
          # :except takes precedence over :only. If :only is not set
          # for a N level model but is set for the N+1 level models,
          # then because :except is set to a default value, the second
          # level model can have both :except and :only set. So if
          # :only is set, always delete :except.
          def serializable_attributes
            #attribute_names = @record.attributes.keys # This includes all attributes including associations
            attribute_names = @record.class.keys.keys # This includes just keys
            idex = attribute_names.index("_id")
            attribute_names[idex] = "id" if idex

            if options[:only]
              options.delete(:except)
              attribute_names = attribute_names & Array(options[:only]).collect { |n| n.to_s }
            else
              options[:except] = Array(options[:except]) 
              attribute_names = attribute_names - options[:except].collect { |n| n.to_s }
            end

            attribute_names.collect { |name| Attribute.new(name, @record) }
          end

          def serializable_method_attributes
            Array(options[:methods]).collect { |name| MethodAttribute.new(name.to_s, @record) }
          end

          def add_attributes
            (serializable_attributes + serializable_method_attributes).each do |attribute|
              add_tag(attribute)
            end
          end

          def add_includes
            if include_associations = options.delete(:include)
              root_only_or_except = { :except => options[:except],
                                      :only => options[:only] }

              include_has_options = include_associations.is_a?(Hash)

              for association in include_has_options ? include_associations.keys : Array(include_associations)
                association_options = include_has_options ? include_associations[association] : root_only_or_except

                opts = options.merge(association_options)

                case @record.class.associations[association].type
                when :many, :has_and_belongs_to_many
                  records = @record.send(association).to_a
                  unless records.empty?
                    tag = association.to_s
                    tag = tag.dasherize if dasherize?

                    builder.tag!(tag) do
                      records.each { |r| r.to_xml(opts.merge(:root=>r.class.to_s.underscore)) }
                    end
                  end
                when :has_one, :belongs_to
                  if record = @record.send(association)
                    record.to_xml(opts.merge(:root => association))
                  end
                end
              end

              options[:include] = include_associations
            end
          end

          def add_procs
            if procs = options.delete(:procs)
              [ *procs ].each do |proc|
                proc.call(options)
              end
            end
          end


          def add_tag(attribute)
            if attribute.type == :array 
              builder.tag!(
                dasherize? ? attribute.name.dasherize.pluralize : attribute.name.pluralize,
                attribute.decorations(!options[:skip_types])
              ) do |x|
                attribute.value.each do |val|
                  if val.respond_to? :to_xml
                    x << val.to_xml(:skip_instruct => true, :root => attribute.name.dasherize.singularize)
                  else
                    x.tag!(
                      dasherize? ? attribute.name.dasherize.singularize : attribute.name.singularize,
                      val.to_s
                    )
                  end
                end
              end
            else
              builder.tag!(
                dasherize? ? attribute.name.dasherize : attribute.name,
                attribute.value.to_s,
                attribute.decorations(!options[:skip_types])
              )
            end
          end

          def serialize
            args = [root]
            if options[:namespace]
              args << {:xmlns=>options[:namespace]}
            end

            builder.tag!(*args) do
              add_attributes
              add_includes
              add_procs
              yield builder if block_given?
            end
          end

          alias_method :to_s, :serialize

          class Attribute #:nodoc:
            attr_reader :name, :value, :type

            def initialize(name, record)
              @name, @record = name, record

              @type = compute_type
              @value = compute_value
            end

            # There is a significant speed improvement if the value
            # does not need to be escaped, as #tag! escapes all values
            # to ensure that valid XML is generated. For known binary
            # values, it is at least an order of magnitude faster to
            # Base64 encode binary values and directly put them in the
            # output XML than to pass the original value or the Base64
            # encoded value to the #tag! method. It definitely makes
            # no sense to Base64 encode the value and then give it to
            # #tag!, since that just adds additional overhead.
            def needs_encoding?
              ![ :binary, :date, :datetime, :boolean, :float, :integer ].include?(type)
            end

            def decorations(include_types = true)
              decorations = {}

              if type == :binary
                decorations[:encoding] = 'base64'
              end

              if include_types && type != :string
                decorations[:type] = type
              end

              decorations
            end

            protected
              def compute_type
                if name == "id"
                  return :object_id
                end

                #type = @record.class.serialized_attributes.has_key?(name) ? :yaml : @record.class.columns_hash[name].type
                v = @record.class.keys[name]
                #puts "Value type is...........  #{v.type.to_s} #{v.type.to_s.blank?}"

                #type = @record.send(name).class

                type = v.nil? ? :yaml : (v.type.to_s.blank? ? :key : v.type.to_s.underscore.to_sym)

                case type
                  when :text
                    :string
                  when :time
                    :datetime
      #            when :array
      #              :yaml
                  else
                    type
                end
              end

              def compute_value
                n = name == "id" ? "_id" : name

                value = @record.send(n)

                #if formatter = Hash::XML_FORMATTING[type.to_s]
                 # value ? formatter.call(value) : nil
                #else
                  value
                #end
              end
          end

          class MethodAttribute < Attribute #:nodoc:
            protected
              def compute_type
                Hash::XML_TYPE_NAMES[@record.send(name).class.name] || :string
              end
          end
      end      

    end
  end
end