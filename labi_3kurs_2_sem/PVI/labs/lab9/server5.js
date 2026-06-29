const express = require('express');
const bodyParser = require('body-parser');
const xml2js = require('xml2js');

const app = express();
const port = 3005;

const parser = new xml2js.Parser({ explicitArray: true });
const builder = new xml2js.Builder({ headless: true });


app.use(bodyParser.text({ type: 'application/xml' }));

app.post('/', async (req, res) => {
    try {
        const xml = req.body;
        // парсим XML-запрос
        const result = await parser.parseStringPromise(xml);
        const requestId = result.request.$.id;

        const xValues = result.request.x.map(x => Number(x.$.value));
        const mValues = result.request.m.map(m => m.$.value);

        const sumX = xValues.reduce((a, b) => a + b, 0);
        const concatM = mValues.join('');

        const responseObj = {
            response: {
                $: {
                    id: "33",
                    request: requestId
                },
                sum: {
                    $: {
                        element: "x",
                        result: sumX.toString()
                    }
                },
                concat: {
                    $: {
                        element: "m",
                        result: concatM
                    }
                }
            }
        };

        const responseXml = builder.buildObject(responseObj);

        res.set('Content-Type', 'application/xml');
        res.status(200).send(responseXml);

    } catch (error) {
        console.error('Ошибка обработки XML:', error.message);
        res.status(400).send('Ошибка разбора XML');
    }
});

app.listen(port, () => {
    console.log(`Express сервер 09-05 запущен на http://localhost:${port}`);
});
9