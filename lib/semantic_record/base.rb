#require "ruby-sesame"

module SemanticRecord
  class Base
    include SesameAdapter

    def Base.inherited(subClass)

      ###
      ### attribute accessors that are independet from superclass
      ###
      class << self
        attr_accessor :rdf_type, :attributes, :base_uri, :attributes_names
      end
      
      attr_accessor :instance_type
      
      subClass.base_uri="http://example.org/music#"
      subClass.rdf_type = subClass.name#.split("::").last.to_s
      subClass.attributes = {}

      def subClass.construct_attributes
        self.attributes, self.attributes_names = ResultParserJson.hash_values(self.query("SELECT ?property_name ?property_type WHERE { ?property_name rdfs:domain <#{uri}>; rdfs:range ?property_type }"))
      end
      
      def subClass.construct_methods
        attr_accessor *(attributes_names) unless attributes_names.empty?
      end 

      def subClass.uri
        # TODO change my name
        "#{base_uri}#{rdf_type}"
      end

      def subClass.find(uri_or_scope)
        instances = ResultParserJson.parse(self.query("SELECT ?uri #{attributes_names.to_sparql_properties} WHERE { ?uri rdf:type <#{uri}> #{attributes.to_optional_clause} }") )
        bla = []
        instances.each {|k|
          bla << new()
        }
        
        return bla
      end

      

      def subClass.attributes_names
        attributes.keys.collect {|key|
          key.to_human_name
        }
      end

      ###
      ### class initializer calls
      ###

      subClass.construct_attributes
      subClass.construct_methods
    end
    
    def initialize(values={})
      self.instance_type = "bla"
   #   values.each {|k,v|
#        raise k.inspect
      #   self.se=v
      # }
    end
  end
end