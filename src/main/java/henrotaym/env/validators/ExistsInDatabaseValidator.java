package henrotaym.env.validators;

import henrotaym.env.annotations.ExistsInDatabase;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.math.BigInteger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.data.jpa.repository.JpaRepository;

public class ExistsInDatabaseValidator
    implements ConstraintValidator<ExistsInDatabase, BigInteger> {

  private Class<? extends JpaRepository<?, BigInteger>> repositoryClass;

  @Autowired ApplicationContext applicationContext;

  @Override
  public void initialize(ExistsInDatabase constraintAnnotation) {
    this.repositoryClass = constraintAnnotation.repository();
  }

  @Override
  public boolean isValid(BigInteger value, ConstraintValidatorContext context) {
    if (value == null) {
      return false;
    }

    return this.applicationContext.getBean(this.repositoryClass).existsById(value);
  }
}
