var _this = this;

this.on('load', function(data) {
  return _this.widget.lines = [];
});

this.on('transmission', function(data) {
  var line;
  line = data.line.replace(/\[90m/g, '<span class="grey">').replace(/\[32m/g, '<span class="green">').replace(/\[33m/g, '<span class="gold">').replace(/\[36m/g, '<span class="lightblue">').replace(/\[0m/g, '<span class="default">');
  _this.widget.lines.push(line);
  _this.widget.append("<div>" + line + "</div>");
  if (_this.widget.lines.length > 14) {
    _this.widget.lines.shift();
    return _this.widget.find("div:first").remove();
  }
});