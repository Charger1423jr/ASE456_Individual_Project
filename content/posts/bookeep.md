---
title: "Bookeep - ASE456 Individual Project"
date: 2024-11-23
draft: false
description: "A multi-platform application designed to track books read by users, compute statistics, and visualize progress over time."
tags: ["flutter", "nodejs", "mongodb", "book-tracking", "reading"]
categories: ["projects"]
author: "Preston Jackson"
---

# Bookeep - ASE456 Individual Project

**Bookeep** is a multi-platform application designed to track books read by users, compute statistics, and visualize progress over time. It is intended for personal or competitive reading tracking, making it easier to log books, calculate points, and manage reading data efficiently.

---

## Table of Contents
1. [Project Goals](#project-goals)  
2. [Problem Statement](#problem-statement)  
3. [Solution](#solution)  
4. [Features](#features)  
5. [Tech Stack](#tech-stack)  
6. [Setup Instructions](#setup-instructions)  
7. [How the Program Works](#how-the-program-works)  
8. [Weekly Progress Reports](#weekly-progress-reports)  
9. [Known Issues](#known-issues)  
10. [Future Enhancements](#future-enhancements)  

---

## Project Goals
- Develop a high-quality, user-friendly application to track books and reading progress.
- Allow users to calculate total word counts, points, and yearly statistics.
- Provide a reliable alternative to text-based tracking for reading competitions.

---

## Problem Statement
Currently, users track reading competitions through text chats, which is:
- Hard to follow
- Prone to errors or manipulation
- Inefficient for tracking statistics over time

**Goal:** Provide a centralized platform to track books, word counts, and points for multiple users.

---

## Solution
Bookeep solves this problem by allowing users to:
1. Enter book title, word count, and date finished.
2. Store the data in a centralized database.
3. Calculate total word counts, points, and yearly statistics automatically.
4. View, edit, or delete books easily through a clean interface.
5. Filter and search books in real-time.

---

## Features
- **Add Books:** Log a book with title, word count, and finished date.  
- **Edit Books:** Update title, word count, or finished date inline.  
- **Delete Books:** Remove a book with a confirmation dialog.  
- **Search & Filter:** Real-time book search by title.  
- **Statistics Dashboard:**  
  - Total words read  
  - Words read in the current year  
  - Total books read  
  - Points (calculated as words/year ÷ 10,000)  
- **Formatting Utilities:** Word count formatted with commas for readability.  
- **Date Picker:** Select finished dates easily for each book.  
- **Responsive UI:** Scrollable interface with themed design using Google Fonts and Material design.  
- **Backend Integration:** Node.js + Express API connected to MongoDB for CRUD operations.  

---

## Tech Stack
- **Frontend:** Flutter (Dart)  
- **Backend:** Node.js, Express  
- **Database:** MongoDB Atlas  
- **Packages/Dependencies:**  
  - `http` (Flutter HTTP requests)  
  - `google_fonts` (Custom fonts)  
  - `cors`, `body-parser` (Node.js API handling)  

---

## Setup Instructions

### Backend
1. Install Node.js and npm.
2. Clone the repository:
   ```bash
   git clone <repo-url>
   cd Bookeep
