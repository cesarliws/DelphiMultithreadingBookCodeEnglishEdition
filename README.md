# Delphi Multithreading: Threads, Concurrency, Parallelism and Asynchronous Programming - Official Source Code

> **Repositório da Edição em Português**
>
> [https://github.com/cesarliws/DelphiMultithreadingBookCode](https://github.com/cesarliws/DelphiMultithreadingBookCode)

This repository contains all the source code for the practical examples in the book **"Delphi Multithreading: Threads, Concurrency, Parallelism and Asynchronous Programming,"** written by Cesar Romero.

## 📖 About the Book

A frozen interface during a long-running operation is the silent enemy of any modern application. This book is the definitive map for mastering concurrent programming in Delphi, guiding the reader from the fundamentals of the classic `TThread` to the mastery of the modern Parallel Programming Library (PPL).

Drawing on 30 years of experience in software architecture, this work is designed to be a complete training course, guiding both the programmer taking their first steps into threads and the architect seeking to optimize performance in high-demand scenarios. By the end of this journey, you will have the confidence and architectural vision to design and build Delphi applications that don't just work—they delight users with their performance and responsiveness.

![Delphi Multithreading - Book Cover](./cover.png)

## 🛒 Where to Buy

The book is available in print format from various stores worldwide.

| Store | Link |
| :--- | :--- |
| 🇺🇸 Amazon.com (USA) | [https://www.amazon.com/dp/6501779057](https://www.amazon.com/dp/6501779057) |
| 🇨🇦 Amazon.ca (Canada) | [https://www.amazon.ca/dp/6501779057](https://www.amazon.ca/dp/6501779057) |
| 🇬🇧 Amazon.co.uk (United Kingdom) | [https://www.amazon.co.uk/dp/6501779057](https://www.amazon.co.uk/dp/6501779057) |
| 🇩🇪 Amazon.de (Germany) | [https://www.amazon.de/dp/6501779057](https://www.amazon.de/dp/6501779057) |
| 🇫🇷 Amazon.fr (France) | [https://www.amazon.fr/dp/6501779057](https://www.amazon.fr/dp/6501779057) |
| 🇪🇸 Amazon.es (Spain) | [https://www.amazon.es/dp/6501779057](https://www.amazon.es/dp/6501779057) |
| 🇮🇹 Amazon.it (Italy) | [https://www.amazon.it/dp/6501779057](https://www.amazon.it/dp/6501779057) |
| 🇳🇱 Amazon.nl (Netherlands) | [https://www.amazon.nl/dp/6501779057](https://www.amazon.nl/dp/6501779057) |
| 🇵🇱 Amazon.pl (Poland) | [https://www.amazon.pl/dp/6501779057](https://www.amazon.pl/dp/6501779057) |
| 🇧🇪 Amazon.com.be (Belgium) | [https://www.amazon.com.be/dp/6501779057](https://www.amazon.com.be/dp/6501779057) |
| 🇮🇪 Amazon.ie (Ireland) | [https://www.amazon.ie/dp/6501779057](https://www.amazon.ie/dp/6501779057) |
| 🇦🇺 Amazon.com.au (Australia) | [https://www.amazon.com.au/dp/6501779057](https://www.amazon.com.au/dp/6501779057) |

-----

## 🚀 About the Projects

This repository is organized into folders by chapter, corresponding to the book's structure. Each example project has been carefully crafted to demonstrate a specific concurrency concept in a practical and isolated manner.

  * **Chapter 1: Introduction to Concurrent and Asynchronous Processing**
      * Demonstrates the "UI Freeze" problem and introduces fundamental theoretical concepts.
  * **Chapter 2: Fundamentals of Threads in Delphi (Basic `TThread`)**
      * Practical examples of creation, lifecycle management, and safe communication with the UI using `Synchronize` and `Queue`.
  * **Chapter 3: Thread Synchronization**
      * Projects demonstrating the use of each synchronization primitive: `TCriticalSection`, `TMonitor`, `TMutex`, `TSemaphore`, `TEvent`, `TLightweightMREW`, `TCountdownEvent`, and `WaitForMultipleObjects`.
  * **Chapter 4: Thread Management and Cancellation**
      * Implementation of patterns for pausing, resuming, and cooperative cancellation (`Terminate`, `TCancellationToken`), as well as exception handling and retry strategies.
  * **Chapter 5: Asynchronous Alternatives**
      * Exploration of asynchronous techniques beyond `TThread`, including communication via `PostMessage` and the Pub/Sub pattern with `System.Messaging`.
  * **Chapter 6: Parallel Programming Library (PPL)**
      * Demonstrations of the PPL's power with `TTask`, `IFuture<T>`, `TParallel.For`, and the coordination of multiple tasks.
  * **Chapter 7: Advanced Threading Topics**
      * Projects that explore building a custom thread pool, using `TInterlocked` for extreme performance, and advanced PPL management.
  * **Chapter 8: Best Practices and Debugging**
      * Examples that consolidate architectural best practices, such as decoupling threads, using `threadvar`, and preventing deadlocks.
  * **Chapter 9: Threads in Mobile Applications (Android and iOS)**
      * FMX projects that solve real-world challenges, like parallel REST requests and processing gallery images without freezing the UI.
  * **Chapter 10: Useful Examples with PPL**
      * Implementation of complex architectural patterns, such as batch file processing, consuming paginated APIs, and pipelines with a state machine.
  * **Chapter 11: Practical Database Applications**
      * The culmination of the book: a complete project demonstrating a senior-level concurrent architecture for database access, using the PPL, Repository, Factory, and Dependency Injection patterns.

## 📚 Full Book Contents

Here is the detailed table of contents for the book.

#### 1: Introduction to Concurrent and Asynchronous Processing

  * 1.1 - The User Interface Freeze Problem (UI Freeze)
  * 1.2 - What Are Concurrent and Asynchronous Processing?
  * 1.3 - A Brief History of Concurrency: From TThread to the PPL
  * 1.4 - The True Goals of Concurrency
  * 1.5 - The Concept of a Thread
  * 1.6 - When NOT to Use Threads (and to Look for Alternatives)

#### 2: Fundamentals of Threads in Delphi (Basic TThread)

  * 2.1 - Creating and Managing Simple Threads
  * 2.2 - Communicating with the Main Thread (Synchronize and Queue)
  * 2.3 - Dealing with Multiple Threads and Shared Data
  * 2.4 - Anonymous Threads (TThread.CreateAnonymousThread)

#### 3: Thread Synchronization

  * 3.1 - TCriticalSection - A Deeper Look at Simple Mutual Exclusion
  * 3.2 - TMonitor - Synchronizing Multiple Threads
  * 3.3 - TMutex - Synchronization Between Processes
  * 3.4 - TSemaphore - Controlling Access to Limited Resources
  * 3.5 - TEvent - Signaling Between Threads
  * 3.6 - Optimizing Concurrent Access: The Readers-Writer Pattern
  * 3.7 - TCountdownEvent - Synchronizing the Completion of Multiple Tasks
  * 3.8 - WaitForMultipleObjects: Coordinated Waiting

#### 4: Thread Management and Cancellation

  * 4.1 - Controlled Start and Pause of Threads
  * 4.2 - Graceful Thread Cancellation (Terminate and WaitFor)
  * 4.3 - Cooperative Cancellation with TCancellationToken
  * 4.4 - Managing Execution Priority (TThread.Priority)
  * 4.5 - Exception Handling in Threads
  * 4.6 - Retry Strategies in Threads

#### 5: Asynchronous Alternatives

  * 5.1 - PostMessage and SendMessage
  * 5.2 - Asynchronous I/O (Overview)
  * 5.3 - Integrating Asynchronous I/O with Threads
  * 5.4 - Asynchronous Execution Pattern on the Main Thread
  * 5.5 - Communication via System.Messaging

#### 6: Parallel Programming Library (PPL)

  * 6.1 - Introduction to the PPL
  * 6.2 - The Heart of the PPL: ITask for Actions and IFuture\<T\> for Results
  * 6.3 - TParallel.For - Parallelizing Loops
  * 6.4 - Task Coordination (WaitForAll, WaitForAny)
  * 6.5 - PPL Task Cancellation
  * 6.6 - Other PPL Features: TParallelArray

#### 7: Advanced Threading Topics

  * 7.1 - Creating a Custom Thread Pool
  * 7.2 - TInterlocked - Atomic Operations
  * 7.3 - Memory Management and Multithreading
  * 7.4 - Advanced PPL Management
  * 7.5 - Conditional Synchronization: TConditionVariableCS

#### 8: Best Practices and Debugging

  * 8.1 - Code Organization
  * 8.2 - Avoiding Concurrency with threadvar
  * 8.3 - Thread-Safe Collections
  * 8.4 - Preventing Deadlocks and Race Conditions
  * 8.5 - Techniques for Minimizing Context Switches
  * 8.6 - Debugging Multithreaded Applications
  * 8.7 - Common Problems and How to Solve Them
  * 8.8 - Final Recommendations

#### 9: Threads in Mobile Applications (Android and iOS)

  * 9.1 - Introduction to Concurrency on Mobile
  * 9.2 - Preventing ANRs on Android
  * 9.3 - Concurrency on iOS: Rules and APIs
  * 9.4 - Platform-Specific Considerations
  * 9.5 - Evolution of Mobile Threading Features
  * 9.6 - Parallel REST Requests
  * 9.7 - Reading and Processing Gallery Images
  * 9.8 - Batch Processing for Maximum Speed
  * 9.9 - Final Recommendations for Mobile

#### 10: Useful Examples with PPL

  * 10.1 - Parallel Processing of Multiple Files
  * 10.2 - Asynchronous Network Requests with Pagination
  * 10.3 - Simulations and Intensive Calculations
  * 10.4 - Orchestrating Complex Workflows
  * 10.5 - Task Pipeline with a State Machine

#### 11: Practical Database Applications

  * 11.1 - The Non-Negotiable Principles (The Doctrine)
  * 11.2 - Essential Example: TDataModule in a TThread
  * 11.3 - Optimization with FireDAC Connection Pooling
  * 11.4 - Thread-less Alternative: Asynchronous Execution (amAsync)
  * 11.5 - Complete Concurrent Architecture with PPL
  * 11.6 - Specific Considerations for DBExpress

#### Appendix

  * Appendix A: Quick Reference Guide to Synchronization Primitives

## 🐞 Feedback and Contributions

This book and its source code are made for the community. Your feedback is essential\!

  * **For Problems with the Source Code:** If you find a bug, have difficulty compiling, or have a suggestion for improving the examples, please **open an Issue** in this repository.
  * **For Errors in the Book's Text:** If you find a typo, an unclear explanation, or a technical inaccuracy in the book's content, please send an email to **delphimultithreadingbook@gmail.com**.

## 👨‍💻 About the Author

**Cesar Romero** is a Software Architect, Embarcadero MVP, and a veteran with nearly 30 years of experience on the Delphi platform. A speaker and instructor, he specializes in designing high-performance systems for Desktop, Cloud, and Mobile, actively sharing his knowledge with the developer community.