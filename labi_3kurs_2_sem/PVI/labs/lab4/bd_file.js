const EventEmitter = require('events');

class DB  {
    constructor() {
        this.data = [];  
        this.counter = 1; 
    }

    // Асинхронно получить все строки из "БД"
    async select() {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve(this.data);
            }, 100);  
        });
    }

    // Асинхронно добавить запись
    async insert(record) {
        return new Promise((resolve) => {
            setTimeout(() => {
                record.id = this.counter++; 
                this.data.push(record);
               
                resolve(record);
            }, 100);  
        });
    }

    // Асинхронно обновить запись
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

    // Асинхронно удалить запись
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
}

module.exports = new DB();
