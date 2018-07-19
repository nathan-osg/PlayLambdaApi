'use strict';

const api = require('lambda-api')();

api.get('/', (req,res) => {
  res.json({ message: 'what do you want from me?' })
});

api.get('/chocolate', (req,res) => {
  res.json({ message: 'yummm....' })
});

api.get('/foo', (req,res) => {
  res.json({ message: 'bar baz qux' })
});


exports.handler = function (event, context, callback) {
  api.run(event, context, callback);
};