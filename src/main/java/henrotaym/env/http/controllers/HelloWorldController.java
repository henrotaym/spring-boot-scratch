package henrotaym.env.http.controllers;

import henrotaym.env.enums.ProfileName;
import henrotaym.env.queues.emitters.Emitter;
import henrotaym.env.queues.events.HelloWorldEvent;
import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@AllArgsConstructor
@RestController
@RequestMapping("hello-world")
@Profile(ProfileName.HTTP)
public class HelloWorldController {
  private Emitter emitter;

  @GetMapping("")
  public ResponseEntity<String> hello() {
    this.emitter.send(new HelloWorldEvent("hello world event"));

    return ResponseEntity.status(HttpStatus.OK).body("hello world");
  }
}
