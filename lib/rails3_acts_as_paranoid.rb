require 'active_record'

module ActsAsParanoid
  def acts_as_paranoid(options = {})
    raise ArgumentError, "Hash expected, got #{options.class.name}" if not options.is_a?(Hash) and not options.empty?
    
    configuration = { :column => "deleted_at", :column_type => "time" }
    configuration.update(options) unless options.nil?

    type = case configuration[:column_type]
      when "time" then "Time.now"
      when "boolean" then "true"
      else
        raise ArgumentError, "'time' or 'boolean' expected for :column_type option, got #{configuration[:column_type]}"
    end
    
    class_eval <<-EOV
      default_scope where("#{self.table_name}.#{configuration[:column]} IS ?", nil)

      class << self
        def with_deleted
          self.unscoped
        end

        def only_deleted
          self.unscoped.
            where("#{self.table_name}.#{configuration[:column]} IS NOT ?
              OR #{self.table_name}.#{configuration[:column]} != ?", nil, true)
        end

        def delete_all!(conditions = nil)
          self.unscoped.delete_all!(conditions)
        end
        
        def delete_all(conditions = nil)
          update_all ["#{configuration[:column]} = ?", #{type}], conditions
        end

        def destroy!
          self.deleted_at = #{type}
          self.save(:validate => false)
        end

        def destroy
          if self.#{configuration[:column]} == nil
            return true if self.deleted_at
            self.deleted_at = #{type}
            self.save(:validate => false)
          else
            self.deleted_at = #{type}
            self.save(:validate => false)
          end
          return true
        end
      end

      def recover
        self.update_attribute(:#{configuration[:column]}, nil)
      end
      
      ActiveRecord::Relation.class_eval do
        alias_method :delete_all!, :delete_all
        alias_method :destroy!, :destroy
      end
    EOV
  end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.extend ActsAsParanoid

