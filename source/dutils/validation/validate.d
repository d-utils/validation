module dutils.validation.validate;

struct ValidationError {
  string path;
  string type;
  string message;
  double[string] parameters;

  string toString() {
    return this.message ~ " (at path " ~ this.path ~ ").";
  }
}

class ValidationErrors : Throwable {
  private ValidationError[] _errors;

  this(ValidationError[] errors) {
    super("Invalid structure: " ~ this.concatenateErrors(errors));
    this._errors = errors;
  }

  static private string concatenateErrors(ValidationError[] errors) {
    auto result = "";
    foreach (error; errors) {
      if (result != "") {
        result ~= " ";
      }
      result ~= error.toString();
    }
    return result;
  }

  @property ValidationError[] errors() {
    return this._errors;
  }
}

void validate(T)(ref T object) {
  validate(object, "");
}

void validate(T)(ref T object, string pathPrefix) {
  import std.traits : isSomeFunction; // , isBuiltinType, isArray;

  ValidationError[] errors;

  static foreach (member; __traits(derivedMembers, T)) {
    static if (!isSomeFunction!(__traits(getMember, T, member))) {
      if (__traits(getMember, object, member)) {
        auto value = __traits(getMember, object, member);

        foreach (attribute; __traits(getAttributes, __traits(getMember, T, member))) {
          static if (isSomeFunction!(attribute.getError)) {
            auto path = pathPrefix.length > 0 ? pathPrefix ~ "." ~ member : member;
            auto result = attribute.getError(value, path);
            if (!result.isNull) {
              errors ~= result;
            }
          }
        }

        /*
        import std.stdio;

        // TODO: add recursive call here and add them to the errors array
        writeln("built in: ", typeof(value).stringof);
        if (isArray!(typeof(value))) {
            foreach (child; value) {
                auto path = pathPrefix.length > 0 ? pathPrefix ~ "." ~ member : member;
                validate(child, path);
            }
        } else if (!isBuiltinType!(typeof(value))) {
            writeln("!built in type");
            //auto childMembers = __traits(derivedMembers, typeof(value));
            //writeln("childMembers: ", childMembers);
            //validate(__traits(getMember, object, member));
        }
        */
      } else {
        import dutils.validation.constraints : ValidateRequired;

        foreach (attribute; __traits(getAttributes, __traits(getMember, T, member))) {
          static if (is(typeof(attribute) == ValidateRequired)) {
            auto path = pathPrefix.length > 0 ? pathPrefix ~ "." ~ member : member;
            auto result = attribute.getError(__traits(getMember, object, member), path);
            if (!result.isNull) {
              errors ~= result;
            }
          }
        }
      }
    }

  }

  if (errors.length > 0 && pathPrefix == "") {
    throw new ValidationErrors(errors);
  }
}

/**
 * validate - Should throw array of ValidationError
 */
unittest {
  import dutils.validation.constraints : ValidateRequired,
    ValidateMinimumLength, ValidateMaximumLength, ValidateMinimum, ValidateEmail;

  struct Person {
    @ValidateRequired()
    @ValidateMinimumLength(2)
    @ValidateMaximumLength(100)
    string name;

    @ValidateMinimum!float(20) float height;

    @ValidateEmail()
    string email;

    // TODO: add when recustion is working
    // Person[] children;
  }

  // TODO: add when recustion is working
  // auto person = Person("a", -1, "notanemail", [Person()]);
  auto person = Person("a", -1, "notanemail");

  auto catched = false;
  try {
    validate(person);
  } catch (ValidationErrors validation) {
    import std.conv : to;

    catched = true;
    assert(validation.errors.length == 3,
        "expected 3 errors, got " ~ validation.errors.length.to!string
        ~ " with message: " ~ validation.msg);
    assert(validation.errors[0].type == "minimumLength", "expected minimumLength error");
    assert(validation.errors[1].type == "minimum", "expected minimum error");
    assert(validation.errors[2].type == "email", "expected email error");
  }

  assert(catched == true, "did not catch the expected errors");
}

/**
 * validate - Should not throw validation errors
 */
unittest {
  import dutils.validation.constraints : ValidateMinimumLength,
    ValidateMaximumLength, ValidateMinimum, ValidateEmail;

  struct Person {
    @ValidateMinimumLength(2)
    @ValidateMaximumLength(100)
    string name;

    @ValidateMinimum!float(20) float height;

    @ValidateEmail()
    string email;
  }

  Person person;
  person.name = "Anna";
  person.height = 167;

  validate(person);
}

/**
 * validate - Should not throw validation errors for nested structs
 */
unittest {
  import dutils.validation.constraints : ValidateRequired,
    ValidateMinimumLength, ValidateMaximumLength, ValidateMinimum, ValidateEmail;

  struct Person {
    @ValidateRequired()
    @ValidateMinimumLength(2)
    @ValidateMaximumLength(100)
    string name;

    @ValidateMinimum!float(20) float height;

    @ValidateEmail()
    string email;

    // TODO: add when recustion is working
    // Person[] children;
  }

  // TODO: add when recustion is working
  // Person child;
  // child.name = "Sofia";

  Person person;
  person.name = "Anna";
  person.height = 167;
  // TODO: add when recustion is working
  // person.children ~= child;

  validate(person);
}
