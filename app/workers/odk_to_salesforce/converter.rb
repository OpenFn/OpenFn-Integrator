module OdkToSalesforce
  ##
  # Convert an ODK data hash into a sailiasforce hash from a mapping
  #
  # odk_form -> { sf_object: { sf_field: "value" } }
  class Converter

    def get_repeat_field_root(odk_field, odk_data)
      arr = []
      hsh = {}

      odk_data.each_pair do |key, value|
        if value.is_a?(Array)
          value.each do |repeat_data|
            arr << repeat_data
          end
        else
          hsh[key] = value
        end
      end

      if arr.empty?
        []
      else
        arr.collect{|r_hash| r_hash.merge!(hsh)}
      end
    end

    def get_field_content(odk_field, odk_data)

      # given "/first_level/second_level"
      # -> [ "first_level", "second_level", etc. ]
      field_nesting = odk_field.field_name.split("/").reject { |f| f.empty? }

      # iterate until data["first_level"]["second_level"] is reached
      value = odk_data.dup
      field_nesting.each do |key|
        if value.kind_of?(Array)
          # => This shouldn't happen, the field should have been marked as a repeat
          raise "Repeat Block not flagged for #{odk_field.field_name}"
        elsif value.has_key?(key)
          value = value[key]
        else
          value = nil
          break
        end
      end
      value = transform_value(value, odk_field.field_type) unless value.is_a?(Array)
      value
    end

    private

    # temporaryly hardcode all staff members as HQ Staff while issue is
    # being sorted out.
    def append_staff_member_type_id(data)
      if data.has_key?(:staff_member__c)
        data[:staff_member__c][:RecordTypeId] = "01290000000hbFGAAY"
      end
      data
    end

    def transform_value(value, data_type)
      # => Transform value from ODK to data_type SF expects
      case data_type
      when "checkbox", "boolean"
        if value.nil? || value.empty? || value.eql?("No")
          value = false
        else
          value = true
        end
      when "double"
        value = value.to_f unless value.nil?
      when "phone"
        value = value.to_s
      end
      value
    end

  end
end
