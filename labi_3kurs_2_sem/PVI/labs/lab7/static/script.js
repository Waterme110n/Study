
fetch('data.json')
    .then(response => response.json())
    .then(data => {
        document.getElementById('json-data').textContent = JSON.stringify(data, null, 2);
    });

fetch('data.xml')
    .then(response => response.text())
    .then(data => {
        document.getElementById('xml-data').textContent = data;
    });
