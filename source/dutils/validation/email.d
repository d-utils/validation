module dutils.validation.email;

import std.regex : ctRegex, replace;

bool isValidEmail(string email) {
  import std.typecons : No;
  import std.net.isemail : isEmail, EmailStatusCode;

  const result = isEmail(extractEmail(email), No.checkDns, EmailStatusCode.none);
  return result.statusCode == EmailStatusCode.valid;
}

const extractEmailPattern = ctRegex!r"^(.*?<\s*)?([^@]+@[^>]+).*$";

string extractEmail(string email) {
  return replace(email, extractEmailPattern, "$2");
}

/**
 * extractEmail - Don't modify string without email
 */
unittest {
  assert(extractEmail("this is not an email<noat>") == "this is not an email<noat>");
}

/**
 * extractEmail - Don't modify string with only email
 */
unittest {
  assert(extractEmail("anna.andersson@example.com") == "anna.andersson@example.com");
}

/**
 * extractEmail - Extract email from string
 */
unittest {
  assert(extractEmail(
      "\"Anna Andersson\" <anna.andersson@example.com>") == "anna.andersson@example.com");
}

/**
 * isValidEmail - Valid email should return true
 */
unittest {
  assert(isValidEmail("\"Anna Andersson\" <anna.andersson@example.com>"));
}

/**
 * isValidEmail - Invalid email should return false
 */
unittest {
  assert(!isValidEmail("\"Anna Andersson\" <anna.anderssonexample.com>"));
  assert(!isValidEmail("Anna Andersson"));
}
