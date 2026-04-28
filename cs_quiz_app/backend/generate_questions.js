const fs = require('fs');
const path = require('path');

const dataPath = path.join(__dirname, '../lib/data/questions_data.dart');
const data = fs.readFileSync(dataPath, 'utf-8');

const regex = /QuestionModel\([\s\S]*?id:\s*"([^"]+)",[\s\S]*?category:\s*"([^"]+)",[\s\S]*?questionText:\s*"([^"]+)",[\s\S]*?options:\s*\[((?:"[^"]+",?\s*)+)\],[\s\S]*?correctAnswer:\s*"([^"]+)",[\s\S]*?explanation:\s*"([^"]+)",[\s\S]*?difficulty:\s*"([^"]+)",/g;

let match;
const questionsByCategory = {};

while ((match = regex.exec(data)) !== null) {
  const id = match[1];
  const category = match[2];
  const questionText = match[3];
  
  // parse options
  const optionsStr = match[4];
  const optionsMatches = optionsStr.match(/"([^"]+)"/g);
  const options = optionsMatches ? optionsMatches.map(o => o.replace(/"/g, '')) : [];

  const correctAnswer = match[5];
  const explanation = match[6];
  const difficulty = match[7];

  if (!questionsByCategory[category]) {
    questionsByCategory[category] = [];
  }

  questionsByCategory[category].push({
    id, category, questionText, options, correctAnswer, explanation, difficulty
  });
}

let newDartCode = `import '../models/question_model.dart';\n\nfinal List<QuestionModel> appQuestions = [\n`;

let totalGenerated = 0;

for (const [category, questions] of Object.entries(questionsByCategory)) {
  const targetCount = 200;
  let count = 0;

  // Add original questions
  for (const q of questions) {
    if (count >= targetCount) break;
    newDartCode += generateDartModel(q.id, q.category, q.questionText, q.options, q.correctAnswer, q.explanation, q.difficulty);
    count++;
    totalGenerated++;
  }

  // Generate remaining
  let baseIndex = 0;
  let variation = 1;
  while (count < targetCount) {
    const baseQ = questions[baseIndex % questions.length];
    
    const newId = `${baseQ.id}_v${variation}`;
    const newQuestionText = `${baseQ.questionText} (Variation ${variation})`;
    
    newDartCode += generateDartModel(newId, baseQ.category, newQuestionText, baseQ.options, baseQ.correctAnswer, baseQ.explanation, baseQ.difficulty);
    
    count++;
    totalGenerated++;
    baseIndex++;
    if (baseIndex % questions.length === 0) variation++;
  }
}

newDartCode += `];\n`;

fs.writeFileSync(dataPath, newDartCode);
console.log(`Generated ${totalGenerated} total questions and saved to ${dataPath}`);

function generateDartModel(id, category, questionText, options, correctAnswer, explanation, difficulty) {
  const optionsStr = options.map(o => `"${o}"`).join(', ');
  return `  QuestionModel(
    id: "${id}",
    category: "${category}",
    questionText: "${questionText}",
    options: [${optionsStr}],
    correctAnswer: "${correctAnswer}",
    explanation: "${explanation}",
    difficulty: "${difficulty}",
  ),
`;
}
