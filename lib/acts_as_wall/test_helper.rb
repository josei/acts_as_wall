module ActiveRecord
  module Acts
    module Wall
      module TestHelper

        def assert_no_event
          assert_no_difference '::Announcement.count' do
            assert_no_difference '::Notification.count' do
              assert_no_difference '::Event.count' do
                yield
              end
            end
          end
        end

        def assert_event options={}
          check_mails = options[:notifications] || options[:mails]
          public_events = (options[:notifications] and !options[:walls]) ? 0 : nil 

          assert_difference('::Notification.count', options[:notifications] || 0) do
            assert_difference('::Announcement.count', options[:walls] || 0) do
              assert_difference('::Event.public.count', options[:public_events] || public_events || options[:events] || 1) do
                assert_difference('::Event.count', options[:events] || 1) do
                  if options[:mails] || options[:notifications]
                    assert_difference('ActionMailer::Base.deliveries.size', options[:mails] || options[:notifications]) do
                      yield
                    end
                  else
                    yield
                  end
                end
              end
            end
          end
        end

        def assert_listener count=1
          assert_difference '::Listener.count', count do
            yield
          end
        end

        def assert_no_listener
          assert_no_difference '::Listener.count' do
            yield
          end
        end

      end
    end
  end
end
