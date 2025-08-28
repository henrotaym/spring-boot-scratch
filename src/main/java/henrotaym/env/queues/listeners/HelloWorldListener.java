package henrotaym.env.queues.listeners;

import henrotaym.env.annotations.KafkaRetryableListener;
import henrotaym.env.enums.ProfileName;
import henrotaym.env.queues.events.HelloWorldEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Profile(ProfileName.QUEUE)
public class HelloWorldListener implements Listener<HelloWorldEvent> {
  @Override
  @KafkaRetryableListener(HelloWorldEvent.EVENT_NAME)
  public void listen(HelloWorldEvent event) {
    log.info("Consumed " + event.getMessage());
  }
}
