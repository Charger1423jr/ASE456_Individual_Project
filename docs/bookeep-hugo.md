---
title: "Bookeep - ASE456 Individual Project"
date: 2024-11-23
draft: false
---

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
   ```
3. Install dependencies:
   ```bash
   npm install express mongoose cors body-parser
   ```
4. Configure MongoDB Atlas connection - Change in server.js
5. Start the server:
   ```bash
   node server.js
   ```

---

### Frontend (Flutter)
1. Install Flutter SDK and ensure environment is set up.
2. Navigate to the Flutter project:
   ```bash
   cd bookeep_flutter
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

--- 

## How the Program Works
- **Initialization:** Fetches all books from the backend API.
- **Book Management:** Users can add, edit, delete, and search books.
- **Statistics Calculation:**
  - All-time and yearly word counts are computed.
  - Points are calculated by dividing yearly word counts by 10,000.
- **UI Updates:** All changes are reflected immediately in the interface.
- **Data Persistence:** Books are stored in MongoDB and synced via REST API.

--- 

### Testing
- **Widget Testing:** 13 Tests, All Pass (Check by Running `flutter test`)

---

## Weekly Progress Reports

### Sprint 1 – Week 1
**Deadline:** 9/28

**Completed Tasks:**
1. Scaffold created for the project
2. Basic UI designed
3. Calculations for book tracking started

**Metrics:**
- LoC: 42
- Completed Goals: 3/3
- Issues: None

---

### Sprint 1 – Week 2
**Deadline:** 10/5

**Completed Tasks:**
1. Completed calculations
2. Home page layout created
3. Database for book storage created

**Metrics:**
- LoC: 93
- Completed Goals: 3/3
- Issues: Database setup took longer than expected

---

### Sprint 1 – Week 3
**Deadline:** 10/12

**Completed Tasks:**
1. Home page setup completed
2. Calculations implemented onto homepage

**Metrics:**
- LoC: 133
- Completed Goals: 2/2
- Issues: None

---

### Sprint 1 – Week 4
**Deadline:** 10/19

**Completed Tasks:**
1. UI font changes implemented

**Metrics:**
- LoC: 210
- Completed Goals: 1/1
- Issues: None

---

### Sprint 1 – Week 5
**Deadline:** 10/26

**Completed Tasks:**
1. Edit feature implemented
2. Year tracking of books added

**Metrics:**
- LoC: 345
- Completed Goals: 2/2
- Issues: None

---

### Sprint 2 – Week 6
**Deadline:** 11/2

**Completed Tasks:**
1. Yearly book trackers implemented
2. Delete feature added

**Metrics:**
- LoC: 434
- Completed Goals: 2/2
- Issues: None

---

### Sprint 2 – Week 7
**Deadline:** 11/9

**Completed Tasks:**
1. UI colors updated

**Metrics:**
- LoC: 497
- Completed Goals: 1/1
- Issues: None

---

### Sprint 2 – Week 8
**Deadline:** 11/16

**Completed Tasks:**
1. Word count formatting with commas implemented

**Metrics:**
- LoC: 542
- Completed Goals: 1/1
- Issues: None

---

### Sprint 2 – Week 9
**Deadline:** 11/23

**Completed Tasks:**
1. UI completed
2. Points calculation formatted to 2 decimals

**Metrics:**
- LoC: 629
- Completed Goals: 2/2
- Issues: None

---

### Sprint 2 – Week 9
**Deadline:** 11/23

**Completed Tasks:**
1. Wrapped Feature with Screenshot Page
2. Points calculation formatted to 2 decimals

**Metrics:**
- LoC: 883
- Completed Goals: 1/1
- Issues: Initially wanted to have it download a png, but complications with testing and dependencies had be restructure this feature.

---
