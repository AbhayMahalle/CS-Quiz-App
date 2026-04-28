const fs = require('fs');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Question = require('./models/Question');

// Load environment variables
// Try both local and parent directory just in case
dotenv.config();
dotenv.config({ path: '../.env' });

const importData = async () => {
  try {
    const mongoUri = process.env.MONGO_URI || process.env.MONGO_URL;
    await mongoose.connect(mongoUri);
    console.log('MongoDB Connected for Seeder');

    await Question.deleteMany();
    console.log('Cleared existing questions');

    const data = fs.readFileSync('../lib/data/questions_data.dart', 'utf-8');
    
    // Regex to extract all QuestionModel instances
    const regex = /QuestionModel\([\s\S]*?category:\s*"([^"]+)",[\s\S]*?questionText:\s*"([^"]+)",[\s\S]*?options:\s*\[((?:"[^"]+",?\s*)+)\],[\s\S]*?correctAnswer:\s*"([^"]+)",[\s\S]*?explanation:\s*"([^"]+)",[\s\S]*?difficulty:\s*"([^"]+)",/g;
    
    let match;
    const questions = [];
    
    while ((match = regex.exec(data)) !== null) {
      const optionsStr = match[3];
      const options = optionsStr.match(/"([^"]+)"/g).map(s => s.replace(/"/g, ''));
      
      questions.push({
        category: match[1],
        question: match[2],
        options: options,
        correctAnswer: match[4],
        explanation: match[5],
        difficulty: match[6]
      });
    }

    await Question.insertMany(questions);
    console.log(`Data Imported Successfully: ${questions.length} questions injected.`);
    process.exit();
  } catch (error) {
    console.error(`Error with Seeder: ${error.message}`);
    process.exit(1);
  }
};

importData();
