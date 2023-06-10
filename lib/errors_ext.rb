module ErrorsExt
  refine ActiveModel::Errors do
    def types_only
      group_by_attribute.transform_values { |errors| errors.map &:type }
    end
  end
end
  
  