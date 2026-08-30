const path = require('path');
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./src/config/db');
const authRoutes = require('./src/routes/authRoutes');
const profileRoutes = require('./src/routes/profileRoutes');
const activityRoutes = require('./src/routes/activityRoutes');
const { notFound, errorHandler } = require('./src/middleware/errorMiddleware');

dotenv.config({ path: path.resolve(__dirname, '.env') });
connectDB();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'EduAble backend is running.' });
});

app.use('/api/auth', authRoutes);
app.use('/api/user', profileRoutes);
app.use('/api/activity', activityRoutes);

app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});
