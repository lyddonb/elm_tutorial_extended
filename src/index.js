require('basscss/css/basscss.css');
require('font-awesome/css/font-awesome.css');

require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var app = Elm.embed(Elm.Main, mountNode, {getDeleteConfirmation: 0});

app.ports.askDeleteConfirmation.subscribe(function (args) {
  console.log('askDeleteConfirmation', args);
  var id = args[0];
  var message = args[1];
  var response = window.confirm(message);
  if (response) {
    app.ports.getDeleteConfirmation.send(id);
  }
})
