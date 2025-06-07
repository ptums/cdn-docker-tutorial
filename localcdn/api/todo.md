// --- COURSE CRUD ---
router.get("/courses", async (\_, res) => {
const courses = await prisma.course.findMany();
res.json(courses);
});

router.post("/courses", async (req, res) => {
const { name, rounds } = req.body;
const course = await prisma.course.create({ data: { name, rounds } });
res.json(course);
});

// --- GAME CRUD ---
router.get("/games", async (\_, res) => {
const games = await prisma.game.findMany({ include: { scores: true } });
res.json(games);
});

router.post("/games", async (req, res) => {
const { date, courseId, userId, finalNote, finalScore, scores } = req.body;
const game = await prisma.game.create({
data: {
date: new Date(date),
courseId,
userId,
finalNote,
finalScore,
scores: { create: scores },
},
include: { scores: true },
});
res.json(game);
});

// --- SCORE CRUD ---
router.post("/scores", async (req, res) => {
const { gameId, hole, par, score, rating } = req.body;
const s = await prisma.score.create({
data: { gameId, hole, par, score, rating },
});
res.json(s);
});
