module dutils.validation.constraints;

import std.conv : to;
import std.typecons : Nullable;

import dutils.validation.validate : ValidationError;

struct ValidateRequired {
  Nullable!ValidationError getError(T)(T value, string path) {
    if (value) {
      return Nullable!ValidationError.init;
    }

    return Nullable!ValidationError(ValidationError(path,
        ValidationErrorTypes.required, "Required to have a value"));
  }
}

struct ValidateEmail {
  Nullable!ValidationError getError(string value, string path) {
    import dutils.validation.email : isValidEmail;

    if (isValidEmail(value)) {
      return Nullable!ValidationError.init;
    }

    return Nullable!ValidationError(ValidationError(path,
        ValidationErrorTypes.email, "Value must be an email string"));
  }
}

struct ValidateMinimum(T) {
  T minimum;

  Nullable!ValidationError getError(T value, string path) {
    if (value.to!T >= this.minimum) {
      return Nullable!ValidationError.init;
    }

    return Nullable!ValidationError(ValidationError(path, ValidationErrorTypes.minimum,
        "Value cannot be less than " ~ this.minimum.to!string,
        ["minimum": this.minimum.to!double]));
  }
}

struct ValidateMaximum(T) {
  T maximum;

  Nullable!ValidationError getError(T value, string path) {
    if (value.to!T <= this.maximum) {
      return Nullable!ValidationError.init;
    }

    return Nullable!ValidationError(ValidationError(path, ValidationErrorTypes.maximum,
        "Value cannot be greater isBuiltinTypethan " ~ this.maximum.to!string,
        ["maximum": this.maximum.to!double]));
  }
}

struct ValidateMinimumLength {
  uint minimumLength;

  Nullable!ValidationError getError(string value, string path) {
    if (value.length >= this.minimumLength) {
      return Nullable!ValidationError.init;
    }

    return Nullable!ValidationError(ValidationError(path, ValidationErrorTypes.minimumLength,
        "Value cannot be shorter than " ~ this.minimumLength.to!string,
        ["minimumLength": this.minimumLength.to!double]));
  }
}

struct ValidateMaximumLength {
  uint maximumLength;

  Nullable!ValidationError getError(string value, string path) {
    if (value.length <= this.maximumLength) {
      return Nullable!ValidationError.init;
    }

    return Nullable!ValidationError(ValidationError(path, ValidationErrorTypes.maximumLength,
        "Value cannot be longer than " ~ this.maximumLength.to!string,
        ["maximumLength": this.maximumLength.to!double]));
  }
}

enum ValidationErrorTypes {
  type = "type",
  required = "required",
  email = "email",
  minimum = "minimum",
  maximum = "maximum",
  minimumLength = "minimumLength",
  maximumLength = "maximumLength"
}
