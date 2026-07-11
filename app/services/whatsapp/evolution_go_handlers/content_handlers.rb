module Whatsapp::EvolutionGoHandlers::ContentHandlers
  private

  def extract_content
    # Content extraction is handled directly in MessagesUpsert
    Rails.logger.debug 'Evolution Go API: Content processing handled in MessagesUpsert'
  end

  def extract_from_baileys_structure
    # Evolution Go doesn't use Baileys structure in the same way
    Rails.logger.debug 'Evolution Go API: Baileys structure extraction not used'
  end

  # Persist shared-contact (vCard) payloads onto the message, mirroring the
  # classic Evolution handler. Without this the message saved with empty content
  # and no contacts attribute, so the bubble rendered blank.
  def handle_contacts
    message = @evolution_go_message
    contact_msg = message&.dig(:contactMessage)
    contacts_array = message&.dig(:contactsArrayMessage, :contacts)

    contacts = if contact_msg
                 [contact_msg]
               elsif contacts_array
                 contacts_array
               else
                 []
               end

    @message.content_attributes[:contacts] = contacts.map do |contact|
      {
        display_name: contact[:displayName],
        vcard: contact[:vcard]
      }
    end
  end
end
