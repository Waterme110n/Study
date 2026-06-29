const express = require('express');
const app = express();
const port = 3000;


app.all('/', (req, res) => {
  const responseHtml = `
    <h1>Request Info</h1>
    <p>Method: ${req.method}</p>
    <p>URI: ${req.url}</p>
    <p>Headers: ${JSON.stringify(req.headers, null, 2)}</p>
    <p>Body: ${JSON.stringify(req.body, null, 2)}</p>
  `;
  res.send(responseHtml);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});