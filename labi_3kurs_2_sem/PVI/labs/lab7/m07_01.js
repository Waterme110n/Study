const fs = require('fs');
const path = require('path');

const EXT_TO_MIME = {
    'html': 'text/html',
    'css': 'text/css',
    'js': 'text/javascript',
    'png': 'image/png',
    'docx': 'application/msword',
    'json': 'application/json',
    'xml': 'application/xml',
    'mp4': 'video/mp4'
};

class StaticFileHandler {
    constructor(staticDir) {
        this.staticDir = staticDir;
    }

    getMimeType(filePath) {
        const ext = path.extname(filePath).substring(1); 
        return EXT_TO_MIME[ext] || 'application/octet-stream';
    }

    handleFileRequest(res, filePath) {
        const fullPath = path.join(this.staticDir, filePath); 


        if (!fullPath.startsWith(this.staticDir)) {
            res.writeHead(403, { 'Content-Type': 'text/plain' });
            return res.end('Forbidden');
        }

        fs.access(fullPath, fs.constants.F_OK, (err) => {
            if (err) {
                res.writeHead(404, { 'Content-Type': 'text/plain' });
                return res.end('Not Found');
            }

            const mimeType = this.getMimeType(fullPath);
            fs.readFile(fullPath, (err, data) => {
                if (err) {
                    res.writeHead(500, { 'Content-Type': 'text/plain' });
                    return res.end('Internal Server Error');
                }

                res.writeHead(200, { 'Content-Type': mimeType });
                res.end(data);
            });
        });
    }
}

module.exports = StaticFileHandler;
