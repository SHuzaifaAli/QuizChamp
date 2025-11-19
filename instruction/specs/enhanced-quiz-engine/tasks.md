# Enhanced Quiz Engine Implementation Plan

- [x] 1. Set up core domain entities and interfaces
  - Create Question, QuizSession, and UserAnswer entities with Equatable
  - Define repository interfaces for QuestionRepository, AudioService, AnimationService, HeartsService
  - Implement base UseCase classes for quiz operations
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1_

- [x] 2. Implement question data layer with OpenTDB integration
  - [x] 2.1 Create QuestionModel extending Question entity
    - Implement fromJson factory for OpenTDB API response mapping
    - Add answer shuffling logic and correct answer index calculation
    - _Requirements: 5.1, 5.4_
  
  - [x] 2.2 Build OpenTDB API data source
    - Configure Dio client with OpenTDB base URL and retry interceptors
    - Implement fetchQuestions method with category and difficulty parameters
    - Add error handling for network failures and API rate limits
    - _Requirements: 5.1, 5.5_
  
  - [x] 2.3 Implement Hive-based question caching
    - Create Hive adapters for Question model
    - Build local storage methods for caching and retrieving questions
    - Implement cache size management and cleanup logic
    - _Requirements: 5.2, 5.3, 5.5_
  
  - [x] 2.4 Create QuestionRepositoryImpl
    - Combine remote API and local cache with fallback logic
    - Implement cache-first strategy for offline support
    - Add question validation and deduplication
    - _Requirements: 5.1, 5.2, 5.3, 5.5_

- [x] 3. Build audio feedback system
  - [x] 3.1 Implement AudioServiceImpl with audioplayers
    - Preload sound effect files for correct, incorrect, and timeout events
    - Create playback methods with error handling and mute support
    - Implement audio focus management for mobile platforms
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [x] 3.2 Add audio service unit tests
    - Test sound playback functionality and mute behavior
    - Mock audioplayers for isolated testing
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 4. Create animation feedback system
  - [x] 4.1 Implement AnimationServiceImpl with Lottie
    - Create animation widgets for correct, incorrect, and timeout feedback
    - Implement consistent 3-second animation duration
    - Add fallback static images for animation failures
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 4.2 Add animation service tests
    - Test animation widget creation and duration consistency
    - Verify fallback behavior when Lottie fails
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 5. Implement hearts system integration
  - [x] 5.1 Create HeartsServiceImpl
    - Implement heart consumption logic with validation
    - Create stream-based heart count updates
    - Add error handling for insufficient hearts
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [x] 5.2 Add hearts service unit tests
    - Test heart consumption and validation logic
    - Verify stream updates and error conditions
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 6. Build quiz session management use cases
  - [x] 6.1 Create StartQuizUseCase
    - Validate available hearts before starting quiz
    - Fetch and prepare questions for quiz session
    - Initialize QuizSession entity with consumed heart
    - _Requirements: 4.1, 4.2, 5.1, 5.5_
  
  - [x] 6.2 Implement AnswerQuestionUseCase
    - Process user answer selection and validation
    - Calculate timing and correctness metrics
    - Update QuizSession with UserAnswer data
    - _Requirements: 1.5, 2.1, 2.2, 3.1, 3.2_
  
  - [x] 6.3 Create QuestionTimerUseCase
    - Implement 30-second countdown timer with stream updates
    - Handle timer expiration and automatic progression
    - Provide timer stop functionality for answered questions
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 7. Implement QuizBloc with state management
  - [x] 7.1 Define quiz events and states
    - Create all quiz events (StartQuizEvent, AnswerSelectedEvent, etc.)
    - Define quiz states with proper Equatable implementation
    - Add state transition validation and error states
    - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1_
  
  - [x] 7.2 Build QuizBloc event handlers
    - Implement StartQuizEvent handler with hearts validation
    - Create AnswerSelectedEvent handler with feedback coordination
    - Add TimerExpiredEvent handler for timeout scenarios
    - Build AnimationCompletedEvent handler for progression
    - _Requirements: 1.1, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4_
  
  - [x] 7.3 Add QuizBloc unit tests
    - Test all state transitions and event handling
    - Mock dependencies and verify use case calls
    - Test error scenarios and recovery flows
    - _Requirements: All requirements_

- [x] 8. Create quiz UI components
  - [x] 8.1 Build QuizScreen widget
    - Create main quiz layout with BlocBuilder integration
    - Implement question display with timer UI
    - Add answer selection buttons with interaction handling
    - _Requirements: 1.1, 1.2, 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 8.2 Implement QuestionCard widget
    - Create animated question card with slide/flip transitions
    - Add question text display with proper formatting
    - Implement answer options layout with touch targets
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 8.3 Build TimerWidget component
    - Create circular progress indicator for countdown
    - Display remaining seconds with visual emphasis
    - Add timer expiration visual feedback
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 8.4 Create FeedbackOverlay widget
    - Integrate Lottie animations for answer feedback
    - Coordinate animation display with audio playback
    - Implement overlay dismissal and progression logic
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3_

- [x] 9. Integrate services with dependency injection
  - [x] 9.1 Register services in GetIt container
    - Add all repository implementations to service locator
    - Register audio and animation services as singletons
    - Configure QuizBloc with proper dependency injection
    - _Requirements: All requirements_
  
  - [x] 9.2 Update main app initialization
    - Initialize Hive database with Question adapters
    - Preload audio files during app startup
    - Set up service container before app launch
    - _Requirements: 3.5, 5.2, 5.3_

- [x] 10. Add error handling and edge cases
  - [x] 10.1 Implement comprehensive error states
    - Create error UI components for network failures
    - Add retry mechanisms for failed operations
    - Implement graceful degradation for missing features
    - _Requirements: 4.5, 5.3, 5.5_
  
  - [x] 10.2 Handle quiz session edge cases
    - Manage app backgrounding during active quiz
    - Handle device rotation and screen size changes
    - Implement proper cleanup on quiz abandonment
    - _Requirements: 1.4, 1.5, 6.5_

- [x] 11. Integration testing and validation
  - [x] 11.1 Create end-to-end quiz flow tests
    - Test complete quiz session from start to finish
    - Verify hearts consumption and question progression
    - Test offline functionality with cached questions
    - _Requirements: All requirements_
  
  - [x] 11.2 Add performance and stress testing
    - Test with large question sets and rapid interactions
    - Verify memory usage during extended quiz sessions
    - Test animation and audio performance on low-end devices
    - _Requirements: 2.3, 2.4, 3.5, 6.2, 6.5_