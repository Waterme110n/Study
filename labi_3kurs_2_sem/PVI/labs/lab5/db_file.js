const EventEmitter = require('events');

class DB extends EventEmitter {
    constructor() {
        super();
        this.data = [];
        this.counter = 1;
    }

    async select() {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve(this.data);
            }, 100);
        });
    }

    async insert(record) {
        return new Promise((resolve) => {
            setTimeout(() => {
                record.id = this.counter++;
                this.data.push(record);
                resolve(record);
            }, 100);
        });
    }

    async update(updatedRecord) {
        return new Promise((resolve) => {
            setTimeout(() => {
                const index = this.data.findIndex(item => item.id === updatedRecord.id);
                if (index !== -1) {
                    this.data[index] = updatedRecord;
                    resolve(updatedRecord);
                } else {
                    resolve(null);
                }
            }, 100);
        });
    }

    async delete(id) {
        return new Promise((resolve) => {
            setTimeout(() => {
                const index = this.data.findIndex(item => item.id === id);
                if (index !== -1) {
                    const deleted = this.data.splice(index, 1)[0];
                    resolve(deleted);
                } else {
                    resolve(null);
                }
            }, 100);
        });
    }

    async commit() {
        return new Promise((resolve) => {
            setTimeout(() => {
                this.emit('COMMIT');
                resolve();
            }, 100);
        });
    }
}

module.exports = new DB();