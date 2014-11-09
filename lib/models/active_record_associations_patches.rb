module ActiveRecordAssociationsPatches
  extend ActiveSupport::Concern
  
  # This fixes a bug in ActiveRecord Association Callbacks.
  # https://github.com/rails/rails/issues/7618
  #
  # For example `group.members.destroy(user)` would not call the `before_destroy` callbacks
  # on the memberships (i.e. the through_records of the HasManyThrough association).
  #
  def destroy(*records)
    if self.class.name == "ActiveRecord::Associations::HasManyThroughAssociation"
      through_association.load_target
      records.each do |record|
        through_records_for(record).each do |through_record|
          through_record.before_remove if through_record.respond_to? :before_remove
        end
      end
    end
    super(*records)
  end
  
end

ActiveRecord::Associations::CollectionAssociation.send(:prepend, ActiveRecordAssociationsPatches)
