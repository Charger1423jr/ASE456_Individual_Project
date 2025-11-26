import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import bodyParser from "body-parser";

const app = express();
app.use(cors());
app.use(bodyParser.json());

mongoose.connect(
  "mongodb+srv://Charger1423:Password123@bookeepdata.2hv2ytt.mongodb.net/?retryWrites=true&w=majority&appName=BookeepData"
)
.then(() => console.log("MongoDB connected successfully!"))
.catch(err => console.error("MongoDB connection error:", err));

const bookSchema = new mongoose.Schema({
  title: String,
  wordCount: Number,
  dateRead: String,
});

const Book = mongoose.model("Book", bookSchema);

app.post("/api/books", async (req, res) => {
  try {
    if (req.body.wordCount) {
      req.body.wordCount = Number(String(req.body.wordCount).replace(/,/g, ""));
    }

    const newBook = new Book(req.body);
    await newBook.save();
    res.json({ message: "Book saved successfully!" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/books", async (req, res) => {
  try {
    const books = await Book.find();
    res.json(books);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/wrapped/:year", async (req, res) => {
  try {
    const year = parseInt(req.params.year);
    const books = await Book.find();
    
    const yearBooks = books.filter(book => {
      try {
        const parts = book.dateRead.split("-");
        if (parts.length === 3) {
          const bookYear = parseInt(parts[2]);
          return bookYear === year;
        }
        return false;
      } catch {
        return false;
      }
    });

    const totalBooks = yearBooks.length;
    const totalWords = yearBooks.reduce((sum, book) => sum + (book.wordCount || 0), 0);
    const points = totalWords / 10000;
    
    const topBooks = yearBooks
      .sort((a, b) => b.wordCount - a.wordCount)
      .slice(0, 5)
      .map(book => ({
        title: book.title,
        wordCount: book.wordCount
      }));

    res.json({
      year,
      totalBooks,
      totalWords,
      points: parseFloat(points.toFixed(2)),
      topBooks
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put("/api/books/:id", async (req, res) => {
  try {
    if (req.body.wordCount) {
      req.body.wordCount = Number(String(req.body.wordCount).replace(/,/g, ""));
    }

    const updatedBook = await Book.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    if (!updatedBook) {
      return res.status(404).json({ error: "Book not found" });
    }

    res.json({ message: "Book updated successfully!", book: updatedBook });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete("/api/books/:id", async (req, res) => {
  try {
    const deleted = await Book.findByIdAndDelete(req.params.id);

    if (!deleted) {
      return res.status(404).json({ error: "Book not found" });
    }

    res.json({ message: "Book deleted successfully!" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(5000, () => console.log("Server running on port 5000"));
