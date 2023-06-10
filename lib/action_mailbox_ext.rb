module ActionMailboxExt
  refine ActionMailbox::Base do
    def bounce_with(message, deliver_now: false)
      inbound_email.bounced!
      if deliver_now
        message.deliver_now
      else
        message.deliver_later
      end
    end
  end
end