Now, let's create each collection:
1. users Collection
This will hold your player profiles. We'll add one sample user to kick things off.
	1	Click "+ Start collection" (or "Add collection" if you have existing data).
	2	In the "Collection ID" field, type exactly: users
	3	Click "Next" .
	4	For the "Document ID", you can click "Auto-ID" (Firestore will generate a unique ID) or type a test UID like testUser123 (this would be the Firebase Authentication UID). For this example, let's use "Auto-ID" .
	5	Now, add the fields one by one, ensuring exact names and types:
	◦	Field 1: uid (Type: string , Value: yourGeneratedUID or testUser123 )
	◦	Field 2: email (Type: string , Value: test@example.com )
	◦	Field 3: displayName (Type: string , Value: QuizChampion Player )
	◦	Field 4: photoURL (Type: string , Value: https://example.com/avatar.jpg or leave blank for null )
	◦	Field 5: createdAt (Type: timestamp , Value: Click "Set to current timestamp")
	◦	Field 6: lastLoginAt (Type: timestamp , Value: Click "Set to current timestamp" or leave blank for null )
	◦	Field 7: isOnline (Type: boolean , Value: true )
	◦	Field 8: friends (Type: array , Value: Click the array type, then click "+ Add item" and add a string value like "anotherUserUID" . You can leave it empty [] for now.)
	◦	Field 9: stats (Type: map )
	▪	Click the map type.
	▪	Inside the map, add these fields:
	▪	totalQuizzes (Type: number , Value: 0 )
	▪	correctAnswers (Type: number , Value: 0 )
	▪	accuracyPercentage (Type: number , Value: 0.0 )
	▪	currentStreak (Type: number , Value: 0 )
	▪	longestStreak (Type: number , Value: 0 )
	▪	totalPoints (Type: number , Value: 0 )
	▪	lastQuizDate (Type: timestamp , Value: Leave blank for null initially, or set to current timestamp)
	6	Click "Save" .
2. challenges Collection
This collection will manage your quiz challenges. Let's create a pending challenge example.
	1	Click "+ Add collection" (next to the users collection).
	2	Collection ID: challenges
	3	Click "Next" .
	4	Document ID: Click "Auto-ID" (this will be your challenge UUID).
	5	Add the fields:
	◦	Field 1: id (Type: string , Value: Copy the auto-generated Document ID here)
	◦	Field 2: challengerId (Type: string , Value: testUser123 )
	◦	Field 3: challengedId (Type: string , Value: opponentUser456 )
	◦	Field 4: challengerName (Type: string , Value: QuizMaster )
	◦	Field 5: challengedName (Type: string , Value: OpponentPro )
	◦	Field 6: challengerPhotoUrl (Type: string , Value: https://example.com/challenger.jpg or leave blank)
	◦	Field 7: challengedPhotoUrl (Type: string , Value: https://example.com/challenged.jpg or leave blank)
	◦	Field 8: category (Type: string , Value: Science )
	◦	Field 9: difficulty (Type: string , Value: medium )
	◦	Field 10: status (Type: string , Value: pending )
	◦	Field 11: questions (Type: array )
	▪	Click the array type.
	▪	Click "+ Add item", choose map .
	▪	Inside the map, add these question fields:
	▪	id (Type: string , Value: q1_sci_easy )
	▪	category (Type: string , Value: Science )
	▪	difficulty (Type: string , Value: easy )
	▪	questionText (Type: string , Value: What is H2O? )
	▪	correctAnswer (Type: string , Value: Water )
	▪	incorrectAnswers (Type: array , Value: Add string items: "Oxygen" , "Hydrogen" )
	▪	shuffledAnswers (Type: array , Value: Add string items: "Oxygen" , "Water" , "Hydrogen" )
	▪	correctAnswerIndex (Type: number , Value: 1 )
	◦	Field 12: createdAt (Type: timestamp , Value: "Set to current timestamp")
	◦	Field 13: expiresAt (Type: timestamp , Value: Set to a future timestamp, or leave blank for null )
	◦	Field 14-16: acceptedAt , completedAt , result , winner (Type: timestamp / map / string , leave all blank for null as the status is pending )
	6	Click "Save" .
3. social_activities Collection
To log user activities and build a feed.
	1	Click "+ Add collection" .
	2	Collection ID: social_activities
	3	Click "Next" .
	4	Document ID: Click "Auto-ID" .
	5	Add the fields:
	◦	Field 1: id (Type: string , Value: Copy the auto-generated Document ID here)
	◦	Field 2: userId (Type: string , Value: testUser123 )
	◦	Field 3: userName (Type: string , Value: QuizChampion Player )
	◦	Field 4: userPhotoUrl (Type: string , Value: https://example.com/player_photo.jpg or leave blank)
	◦	Field 5: type (Type: string , Value: quizCompleted )
	◦	Field 6: data (Type: map )
	▪	Click the map type.
	▪	Inside the map, add these fields (for quizCompleted type):
	▪	score (Type: number , Value: 100 )
	▪	totalQuestions (Type: number , Value: 10 )
	▪	category (Type: string , Value: History )
	▪	timeTaken (Type: string , Value: PT1M30S )
	◦	Field 7: description (Type: string , Value: QuizChampion Player completed a History quiz! )
	◦	Field 8: timestamp (Type: timestamp , Value: "Set to current timestamp")
	◦	Field 9: reactions (Type: array , Value: Leave as an empty [] for now, or add an example map item if you want to test reactions with a structure like: { userId: "reactingUser", userName: "Reacting User", type: "like", timestamp: current timestamp } )
	◦	Field 10: isVisible (Type: boolean , Value: true )
	6	Click "Save" .
4. questions Collection
Your question bank.
	1	Click "+ Add collection" .
	2	Collection ID: questions
	3	Click "Next" .
	4	Document ID: Click "Auto-ID" .
	5	Add the fields:
	◦	Field 1: id (Type: string , Value: Copy the auto-generated Document ID here)
	◦	Field 2: category (Type: string , Value: Geography )
	◦	Field 3: difficulty (Type: string , Value: easy )
	◦	Field 4: questionText (Type: string , Value: What is the capital of France? )
	◦	Field 5: correctAnswer (Type: string , Value: Paris )
	◦	Field 6: incorrectAnswers (Type: array , Value: Add string items: "London" , "Berlin" , "Rome" )
	◦	Field 7: shuffledAnswers (Type: array , Value: Add string items: "London" , "Paris" , "Berlin" , "Rome" )
	◦	Field 8: correctAnswerIndex (Type: c , Value: 1 )
	◦	Field 9: createdAt (Type: timestamp , Value: "Set to current timestamp")
	◦	Field 10: isActive (Type: boolean , Value: true )
	6	Click "Save" .