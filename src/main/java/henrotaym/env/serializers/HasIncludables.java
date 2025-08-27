package henrotaym.env.serializers;

import com.fasterxml.jackson.annotation.JsonFilter;
import java.util.Set;

// TODO reactive to filter relations
// @JsonFilter(value = "include")
public interface HasIncludables {
  public Set<String> includables();
}
