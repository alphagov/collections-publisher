class EmailAlertsUpdater
  def self.call(...)
    new(...).update
  end

  attr_reader :item, :successor

  def initialize(item:, successor:)
    @item = item
    @successor = successor
  end

  def update
    return if topic_successor_is_a_document_collection?

    EmailAlertsUnsubscriber.call(item:, body: unsubscribe_email_body)
  end

private

  # Temporary hack to prevent emails being sent to subscribers of a specialist topic that is being
  # converted to a document collection. Those subscribers will be manually migrated to the new document
  # collection subscription, which will be similar enough that a notification is not required.
  def topic_successor_is_a_document_collection?
    (item.is_a? Topic) && successor.base_path.include?("/government/collections/")
  end

  def unsubscribe_email_body
    <<~BODY
      This topic has been archived. You will not get any more emails about it.

      You can find more information about this topic at [#{Plek.website_root + successor.base_path}](#{Plek.website_root + successor.base_path}).
    BODY
  end
end
