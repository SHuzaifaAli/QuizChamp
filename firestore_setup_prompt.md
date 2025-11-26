# Firestore Database Setup Prompt for Quiz App

## Prompt for Gemini:

Create a Firestore database structure for a Flutter quiz app with the following exact collections and field specifications. All field names, collection names, and data types must match exactly as specified.

## Required Collections:

### 1. `users` Collection
Document ID: Auto-generated Firestore UID
Fields:
- `uid` (String) - Firebase Authentication UID
- `email` (String) - User email address
- `displayName` (String) - User's display name
- `photoURL` (String, nullable) - Profile picture URL
- `createdAt` (Timestamp) - Account creation date
- `lastLoginAt` (Timestamp, nullable) - Last login timestamp
- `isOnline` (Boolean) - Online status
- `friends` (Array of Strings) - List of friend UIDs
- `stats` (Map) - User statistics with nested fields:
  - `totalQuizzes` (Number) - Total quizzes completed
  - `correctAnswers` (Number) - Total correct answers
  - `accuracyPercentage` (Number) - Overall accuracy percentage
  - `currentStreak` (Number) - Current quiz streak
  - `longestStreak` (Number) - Longest streak achieved
  - `totalPoints` (Number) - Total points earned
  - `lastQuizDate` (Timestamp, nullable) - Last quiz completion date

### 2. `challenges` Collection
Document ID: Auto-generated UUID
Fields:
- `id` (String) - Challenge UUID
- `challengerId` (String) - UID of challenge creator
- `challengedId` (String) - UID of challenged user
- `challengerName` (String) - Display name of challenger
- `challengedName` (String) - Display name of challenged user
- `challengerPhotoUrl` (String, nullable) - Challenger's profile photo
- `challengedPhotoUrl` (String, nullable) - Challenged user's profile photo
- `category` (String) - Quiz category
- `difficulty` (String) - Difficulty level (easy, medium, hard)
- `status` (String) - Challenge status (pending, accepted, active, completed, expired, declined)
- `questions` (Array of Maps) - List of question objects:
  - Each question map contains:
    - `id` (String) - Question ID
    - `category` (String) - Question category
    - `difficulty` (String) - Question difficulty
    - `questionText` (String) - The question
    - `correctAnswer` (String) - Correct answer
    - `incorrectAnswers` (Array of Strings) - Wrong answers
    - `shuffledAnswers` (Array of Strings) - All answers shuffled
    - `correctAnswerIndex` (Number) - Index of correct answer
- `createdAt` (Timestamp) - Challenge creation date
- `expiresAt` (Timestamp, nullable) - Challenge expiration date
- `acceptedAt` (Timestamp, nullable) - When challenge was accepted
- `completedAt` (Timestamp, nullable) - When challenge was completed
- `result` (Map, nullable) - Challenge results:
  - `challengerResult` (Map):
    - `userId` (String) - User ID
    - `score` (Number) - Score achieved
    - `correctAnswers` (Number) - Number of correct answers
    - `totalQuestions` (Number) - Total questions in challenge
    - `accuracyPercentage` (Number) - Accuracy percentage
    - `timeToComplete` (String) - Duration in ISO format
    - `completedAt` (Timestamp) - Completion timestamp
    - `answers` (Array of Maps) - User's answers:
      - Each answer map contains:
        - `questionId` (String) - Question ID
        - `selectedAnswer` (String) - User's selected answer
        - `isCorrect` (Boolean) - Whether answer was correct
        - `timeToAnswer` (Number) - Time taken in seconds
  - `challengedResult` (Map) - Same structure as challengerResult
- `winner` (String, nullable) - Winner's UID (challengerId or challengedId)

### 3. `social_activities` Collection
Document ID: Auto-generated UUID
Fields:
- `id` (String) - Activity UUID
- `userId` (String) - User ID who performed the activity
- `userName` (String) - User's display name
- `userPhotoUrl` (String, nullable) - User's profile photo
- `type` (String) - Activity type (quizCompleted, achievementUnlocked, streakAchieved, challengeWon, challengeLost, friendAdded, levelUp, personalBest)
- `data` (Map) - Activity-specific data:
  - For quizCompleted:
    - `score` (Number) - Quiz score
    - `totalQuestions` (Number) - Total questions
    - `category` (String) - Quiz category
    - `timeTaken` (String) - Duration in ISO format
  - For achievementUnlocked:
    - `achievementTitle` (String) - Achievement name
    - `achievementDescription` (String) - Achievement description
  - For streakAchieved:
    - `streakDays` (Number) - Streak length
  - For challengeWon/challengeLost:
    - `challengeId` (String) - Challenge ID
    - `opponentName` (String) - Opponent's name
    - `score` (Number) - User's score
- `description` (String) - Human-readable description
- `timestamp` (Timestamp) - When activity occurred
- `reactions` (Array of Maps) - User reactions:
  - Each reaction map contains:
    - `userId` (String) - Reacting user's ID
    - `userName` (String) - Reacting user's name
    - `type` (String) - Reaction type (like, love, laugh, wow, sad, angry)
    - `timestamp` (Timestamp) - When reaction was added
- `isVisible` (Boolean) - Whether activity is visible in feed

### 4. `questions` Collection (Optional - for question bank)
Document ID: Auto-generated UUID
Fields:
- `id` (String) - Question UUID
- `category` (String) - Question category
- `difficulty` (String) - Difficulty level
- `questionText` (String) - The question
- `correctAnswer` (String) - Correct answer
- `incorrectAnswers` (Array of Strings) - Wrong answers
- `shuffledAnswers` (Array of Strings) - All answers shuffled
- `correctAnswerIndex` (Number) - Index of correct answer
- `createdAt` (Timestamp) - When question was added
- `isActive` (Boolean) - Whether question is active

## Index Requirements:

Create the following Firestore indexes for optimal query performance:

1. **challenges collection**:
   - Composite index: [challengerId, createdAt] (descending)
   - Composite index: [challengedId, createdAt] (descending)
   - Composite index: [status, createdAt] (descending)
   - Composite index: [challengerId, status] (array)
   - Composite index: [challengedId, status] (array)

2. **social_activities collection**:
   - Composite index: [userId, timestamp] (descending)
   - Composite index: [type, timestamp] (descending)
   - Composite index: [isVisible, timestamp] (descending)

3. **users collection**:
   - Composite index: [friends, lastLoginAt] (descending)
   - Single field index: [email] (ascending)

## Security Rules:

Implement the following Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read challenges they're involved in
    match /challenges/{challengeId} {
      allow read: if request.auth != null && 
        (resource.data.challengerId == request.auth.uid || 
         resource.data.challengedId == request.auth.uid);
      allow create: if request.auth != null && 
        (request.resource.data.challengerId == request.auth.uid || 
         request.resource.data.challengedId == request.auth.uid);
      allow update: if request.auth != null && 
        (resource.data.challengerId == request.auth.uid || 
         resource.data.challengedId == request.auth.uid);
    }
    
    // Users can read social activities of themselves and friends
    match /social_activities/{activityId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         request.auth.uid in resource.data.friends);
      allow create: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Questions collection - read-only for authenticated users
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
  }
}
```

## Implementation Instructions:

1. Create all collections with exact field names and data types as specified
2. Set up all required indexes
3. Configure security rules as provided
4. Test with sample data to ensure compatibility with Flutter app
5. Verify all field names match the Dart model classes exactly

## Important Notes:

- All collection and field names are case-sensitive and must match exactly
- Use Timestamp data type for all date/time fields
- Array fields must be properly typed
- Nested Map structures must match the Dart model implementations
- Document IDs should use appropriate formats (UID for users, UUID for others)
