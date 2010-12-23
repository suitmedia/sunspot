module Sunspot
  class RichDocument < RSolr::Message::Document
    include Enumerable

    def contains_attachment?
      @fields.each do |field|
        if field.name.to_s.include?("_attachment")
          return true
        end
      end
      return false
    end

    def add(connection)
      params = {
        :wt => :ruby
      }

      data = nil

      @fields.each do |f|   
        if f.name.to_s.include?("_attachment")
          #data = open(f.value).read
          data = f.value
          params['fmap.content'] = f.name
        else
          param_name = "literal.#{f.name.to_s}"
          params[param_name] = [] unless params.has_key?(param_name)
          params[param_name] << f.value          
        end
        if f.attrs[:boost]
          params["boost.#{f.name.to_s}"] = f.attrs[:boost]
        end
      end

      solr_message = params
      #connection.send('update/extract', solr_message, data)
      puts `curl "#{Sunspot.config.solr.url}/update/extract?#{solr_message.to_query.gsub(/\[\]/, "")}" -F "stream.file=#{data}"`
    end
  end
end
