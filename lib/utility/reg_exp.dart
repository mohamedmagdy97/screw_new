RegExp regExpPhone = RegExp(
  r'^(05)([503649187])(\d{7})', // '[0-9]' can be simplified to '\d'
  caseSensitive: false,
  multiLine: false,
);
RegExp regExpHouseNumber = RegExp(
  r'^(01)([123456789])(\d{7})', // '[0-9]' can be simplified to '\d'
  caseSensitive: false,
  multiLine: false,
);
RegExp regExpEmail = RegExp(
  r'(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))+$',
  caseSensitive: false,
  multiLine: false,
);

RegExp regExpName = RegExp(
  r"^[\p{L} ,.'-]*$",
  caseSensitive: false,
  unicode: true,
  dotAll: true,
  multiLine: false,
);

RegExp regExpNumber =
    RegExp('[a-zA-Z ]*\\d+.*', caseSensitive: false, multiLine: false);

/// Egyptian phone numbers validation
// String pattern = r'^(010|011|012|015)[0-9]{8}$';
// RegExp regExpPhoneNumber = RegExp(r'^(010|011|012|015)\d{8}$');
RegExp regExpPhoneNumber = RegExp(r'^(?:010|011|012|015)[0-9]{8}$'); // sharp