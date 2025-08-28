package henrotaym.env.scheduler;

import henrotaym.env.enums.ProfileName;
import java.util.concurrent.TimeUnit;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Profile(ProfileName.SCHEDULER)
public class HelloWorldJob {
  @Scheduled(timeUnit = TimeUnit.SECONDS, fixedDelay = 10)
  public void handle() {
    log.info("Hello world Scheduler!");
  }
}
