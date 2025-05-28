# TODO

- [x] setup claude code

- [x] research zustand internals

- [ ] claude went and created a whole example, see if something is useful

  Perfect! I have successfully created a comprehensive Flutter MobX architecture example with all the related files. Let
   me summarize what I've created:

  Complete Flutter MobX Architecture Documentation

  I've created a professional, comprehensive example of Flutter application architecture using MobX, optimized for 
  Claude Code. Here's what was delivered:

  📋 Core Architecture Files:

  1. ARCHITECTURE-EXAMPLE.md - Main architecture documentation
  2. README-EXAMPLE.md - Comprehensive usage guide
  3. pubspec-example.yaml - Complete dependencies setup

  🏪 MobX Stores (5 files):

  1. base_store-example.dart - Base store with common functionality
  2. root_store-example.dart - Root store managing all other stores
  3. auth_store-example.dart - Authentication state management
  4. user_store-example.dart - User profile management
  5. theme_store-example.dart - Theme and UI preferences
  6. navigation_store-example.dart - Navigation state management

  🎨 Widget Examples (4 files):

  1. login_page-example.dart - Complete login page with MobX integration
  2. loading_overlay-example.dart - Reusable loading component
  3. error_banner-example.dart - Error display component
  4. user_profile_card-example.dart - Complex profile card with multiple states

  🏗️ Repository Pattern (6 files):

  1. auth_repository-example.dart - Auth repository interface
  2. user_repository-example.dart - User repository interface
  3. preferences_repository-example.dart - Preferences repository interface
  4. auth_repository_impl-example.dart - Auth repository implementation
  5. auth_api_service-example.dart - API service layer
  6. auth_local_service-example.dart - Local storage service

  I've expanded the architecture with additional crucial components. The models and domain layer provide structured data
   handling, while dependency injection ensures clean, modular code organization. I've also included comprehensive 
  testing examples to validate the application's core functionality and maintain high code quality.

  The domain models capture essential data structures, and the dependency injection setup streamlines component 
  management. Testing files demonstrate robust validation of store logic and widget interactions, ensuring the 
  application's reliability and performance.

  Key architectural strengths include reactive state management, professional code separation, and comprehensive error 
  handling strategies. The implementation leverages modern Dart and Flutter practices, with code generation and 
  dependency injection enhancing development efficiency.

  I'll focus on creating a scalable, maintainable codebase that follows industry best practices. The approach 
  prioritizes clean component design, clear documentation, and modular architecture to support long-term project 
  evolution.

● I've created a comprehensive, professional Flutter MobX architecture documentation with all related files, optimized
  for Claude Code. Here's what was delivered:

  📋 Complete Architecture Package

  Core Documentation:
  - ARCHITECTURE-EXAMPLE.md - Main architecture guide with best practices
  - README-EXAMPLE.md - Complete usage guide and setup instructions
  - pubspec-example.yaml - All necessary dependencies

  🏪 MobX Stores (6 files):
  - base_store-example.dart - Common store functionality
  - root_store-example.dart - Central store coordinator
  - auth_store-example.dart - Authentication state management
  - user_store-example.dart - User profile management
  - theme_store-example.dart - Theme and UI preferences
  - navigation_store-example.dart - Navigation state tracking

  🎨 Widget Examples (4 files):
  - login_page-example.dart - Complete login implementation
  - user_profile_card-example.dart - Complex stateful component
  - loading_overlay-example.dart - Reusable loading component
  - error_banner-example.dart - Error display component

  🏗️ Repository Layer (6 files):
  - Repository interfaces and implementations
  - API and local data services
  - Clean separation of data access concerns

  ⚙️ Setup & Testing:
  - injection-example.dart - Dependency injection setup
  - main-example.dart - Complete app configuration
  - Comprehensive unit and widget tests

  ✅ Key Features:
  - Enterprise-grade clean architecture
  - Reactive MobX state management
  - Code generation setup (MobX, JSON, DI)
  - Comprehensive error handling
  - Theme management with dark mode
  - Professional testing examples
  - Claude Code optimized organization

  All files are postfixed with "-example" and follow consistent naming conventions for optimal Claude Code integration.
  The architecture demonstrates latest Flutter best practices with MobX for scalable, maintainable applications.

- [ ] look for github repos with name "wallet" using flutter_mobx, these will be possibly the best ones to use as reference for architecture 

- [ ] Check open Manus AI agent and related libraries https://github.com/FoundationAgents
 
- [ ] for polkawallet-io and start digging into its architecture, its pretty interesting how they handled the crypto libraries in typescript in flutter

- [ ] research cerebral internals
action-chain
https://github.com/search?q=repo%3Acerebral%2Fovermind%20action-chain&type=code
https://github.com/cerebral/cerebral/issues/1363
https://github.com/cerebral/cerebral/issues/1311
https://github.com/cerebral/cerebral/issues/1206

- [ ] TDD for AI development?
https://github.com/jonsamwell/flutter_gherkin
https://www.qodo.ai/blog/ai-code-assistants-test-driven-development/
https://www.readysetcloud.io/blog/allen.helton/tdd-with-ai/
https://dev.to/disukharev/aitdd-ai-cli-for-tdd-you-write-the-test-ai-makes-it-green-32bn
https://www.galaksiya.com/articles/test-driven-development-using-generative-ai-to-create-good-code

- [ ] SEO https://medium.com/@purvangsuvagiya/unlocking-the-seo-potential-of-flutter-web-93bfaaaad2ae

- [ ] Research Document Driven Development
https://docdd.ai/
https://www.writethedocs.org/videos/portland/2019/lessons-learned-in-a-year-of-docs-driven-development-jessica-parsons/
https://www.reddit.com/r/coding/comments/1e0j3q4/a_better_way_to_code_documentation_driven/
https://playfulprogramming.com/posts/documentation-driven-development
https://buildwithandrew.medium.com/whats-documentation-driven-development-4b007f4de6a1
https://news.ycombinator.com/item?id=40749345
https://gist.github.com/zsup/9434452
https://www.waterfall2006.com/beck.html
https://baydis.medium.com/documentation-driven-development-the-only-way-to-code-e1633830cac8


- [ ] Cost per client feature
