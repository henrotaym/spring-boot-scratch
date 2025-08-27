package henrotaym.env.database.factories;

import java.math.BigInteger;
import java.util.function.Consumer;
import lombok.AllArgsConstructor;
import net.datafaker.Faker;
import org.springframework.data.jpa.repository.JpaRepository;

@AllArgsConstructor
public abstract class EntityFactory<T> {
  protected Faker faker;
  private JpaRepository<T, BigInteger> repository;

  protected abstract T entity();

  protected abstract void attributes(T entity);

  protected void relationships(T entity) {}

  public T make(Consumer<T> callback) {
    T entity = this.entity();
    this.attributes(entity);
    callback.accept(entity);
    this.relationships(entity);

    return entity;
  }

  public T make() {
    return this.make((_) -> {});
  }

  public T create(Consumer<T> callback) {
    return this.repository.save(this.make(callback));
  }

  public T create() {
    return this.create((_) -> {});
  }
}
