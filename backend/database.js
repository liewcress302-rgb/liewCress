const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const dbPath = path.join(__dirname, 'shop.db');
const db = new sqlite3.Database(dbPath);

const initDb = () => {
    return new Promise((resolve, reject) => {
        db.serialize(() => {
            // Products Table
            db.run(`CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                price REAL,
                category TEXT
            )`);

            // Orders Table
            db.run(`CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY,
                customer_name TEXT,
                customer_phone TEXT,
                customer_address TEXT,
                total REAL,
                createdAt TEXT
            )`);

            // Order Items Table
            db.run(`CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER,
                product_id INTEGER,
                name TEXT,
                quantity INTEGER,
                price REAL,
                FOREIGN KEY (order_id) REFERENCES orders (id)
            )`);

            // Check if products table is empty and migrate from products.json
            db.get("SELECT COUNT(*) as count FROM products", (err, row) => {
                if (err) return reject(err);
                if (row.count === 0) {
                    console.log('Migrating products from JSON to SQLite...');
                    const productsJsonPath = path.join(__dirname, 'products.json');
                    if (fs.existsSync(productsJsonPath)) {
                        const products = JSON.parse(fs.readFileSync(productsJsonPath, 'utf8'));
                        const stmt = db.prepare("INSERT INTO products (id, name, description, price, category) VALUES (?, ?, ?, ?, ?)");
                        products.forEach(p => {
                            stmt.run(p.id, p.name, p.description, p.price, p.category);
                        });
                        stmt.finalize();
                    }
                }

                // Check and migrate orders
                db.get("SELECT COUNT(*) as count FROM orders", (err, row) => {
                    if (err) return reject(err);
                    if (row.count === 0) {
                        const ordersJsonPath = path.join(__dirname, 'orders.json');
                        if (fs.existsSync(ordersJsonPath)) {
                            console.log('Migrating orders from JSON to SQLite...');
                            const orders = JSON.parse(fs.readFileSync(ordersJsonPath, 'utf8'));
                            orders.forEach(o => {
                                db.run("INSERT INTO orders (id, customer_name, customer_phone, customer_address, total, createdAt) VALUES (?, ?, ?, ?, ?, ?)",
                                    [o.id, o.customer.name, o.customer.phone, o.customer.address, o.total, o.createdAt],
                                    function(err) {
                                        if (err) return;
                                        const stmt = db.prepare("INSERT INTO order_items (order_id, product_id, name, quantity, price) VALUES (?, ?, ?, ?, ?)");
                                        o.items.forEach(item => {
                                            stmt.run(this.lastID || o.id, item.productId, item.name, item.quantity, item.price);
                                        });
                                        stmt.finalize();
                                    }
                                );
                            });
                        }
                    }
                    resolve();
                });
            });
        });
    });
};

module.exports = {
    db,
    initDb
};
