class HashtagParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      tag_list.add @tag_list.scan(SpoopConstants::HASHTAG_REGEX)
    end
  end
end