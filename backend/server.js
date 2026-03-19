const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

const { db, initDb } = require('./database');

// API: Get all products
app.get('/api/products', (req, res) => {
    db.all("SELECT * FROM products", [], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json(rows);
    });
});

// API: Get all orders
app.get('/api/orders', (req, res) => {
    db.all("SELECT * FROM orders ORDER BY createdAt DESC", [], (err, orders) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        
        // Fetch items for each order
        const fetchItemsPromises = orders.map(order => {
            return new Promise((resolve) => {
                db.all("SELECT * FROM order_items WHERE order_id = ?", [order.id], (err, items) => {
                    order.customer = {
                        name: order.customer_name,
                        phone: order.customer_phone,
                        address: order.customer_address
                    };
                    order.items = items || [];
                    resolve(order);
                });
            });
        });

        Promise.all(fetchItemsPromises).then(results => res.json(results));
    });
});

// API: Submit an order
app.post('/api/orders', (req, res) => {
    const { customer, items, total } = req.body;
    const createdAt = new Date().toISOString();
    const orderId = Date.now();

    db.run(`INSERT INTO orders (id, customer_name, customer_phone, customer_address, total, createdAt) 
            VALUES (?, ?, ?, ?, ?, ?)`,
        [orderId, customer.name, customer.phone, customer.address, total, createdAt],
        function(err) {
            if (err) {
                return res.status(500).json({ error: err.message });
            }

            const stmt = db.prepare("INSERT INTO order_items (order_id, product_id, name, quantity, price) VALUES (?, ?, ?, ?, ?)");
            items.forEach(item => {
                stmt.run(orderId, item.productId, item.name, item.quantity, item.price);
            });
            stmt.finalize();

            res.status(201).json({ message: 'Order submitted successfully', orderId });
        }
    );
});

initDb().then(() => {
    app.listen(PORT, () => {
        console.log(`Server is running on http://localhost:${PORT}`);
    });
});
