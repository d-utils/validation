# validation

[![DUB Package](https://img.shields.io/dub/v/dutils-validation.svg)](https://code.dlang.org/packages/dutils-validation)
[![Posix Build Status](https://travis-ci.org/d-utils/validation.svg?branch=master)](https://travis-ci.org/d-utils/validation)

Validation annotations for dlang structs

## example

    import dutils.validation.constraints : ValidateRequired, ValidateEmail

    struct Email {
      @ValidateRequired()
      @ValidateEmail()
      string to;

      @ValidateRequired()
      @ValidateEmail()
      string from;

      @ValidateMinimumLength(3)
      @ValidateMaximumLength(100)
      string subject;

      string body;
    }

    auto email = Email("badto.address", "name@example.com", "no", "some body");

    validate(email); // throws an instance of ValidationErrors

## TODO

- [ ] Support for nested structs and arrays
