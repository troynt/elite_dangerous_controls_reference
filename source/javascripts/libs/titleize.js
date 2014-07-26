String.prototype.titleize = function() {
  var out = this;
  out = out.replace(/^\s*/, "");  // strip leading spaces
  out = out.replace(/_/g, ' ');
  out = out.replace(/^[a-z]|[^\s][A-Z]/g, function(str, offset) {
    if (offset === 0) {
      return(str.toUpperCase());
    } else {
      return(str.substr(0,1) + " " + str.substr(1).toUpperCase());
    }
  });
  return out;
};
