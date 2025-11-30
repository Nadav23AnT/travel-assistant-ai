# Claude Code - Development Assistant Instructions

**Purpose:** This file contains generic, reusable instructions for how Claude Code should work across all projects.
**Project-Specific Documentation:** See `architecture.md` for Waylo-specific architecture, features, database schema, and roadmap.

---

## 🤖 Claude Code - Development Assistant Role

### Full-Stack Development Responsibilities

Claude Code is your full-stack development partner, responsible for:

**Backend Management:**
- ✅ Design and implement all database schemas and table structures
- ✅ Write and execute SQL migrations
- ✅ Create and optimize database relationships and indexes
- ✅ Implement Row Level Security (RLS) policies for all tables
- ✅ Configure authentication flows and session management
- ✅ Build and deploy serverless functions (Edge Functions, Cloud Functions)
- ✅ Handle API integrations and external service connections
- ✅ Set up real-time subscriptions and WebSocket connections
- ✅ Troubleshoot and resolve database-related issues
- ✅ Manage environment variables and API keys securely

**Frontend Development:**
- ✅ Implement backend client integration (Supabase, Firebase, etc.)
- ✅ Build data models and services
- ✅ Create UI screens and components
- ✅ Handle state management and data flow
- ✅ Implement real-time updates in the UI

**Git Workflow Management:**
- ✅ Create feature branches for all new work (NEVER commit to main)
- ✅ Write descriptive commit messages following conventions
- ✅ Create pull requests with comprehensive descriptions
- ✅ Ensure code quality and best practices

**Testing & Quality Assurance:**
- ✅ Write unit tests, widget tests, and integration tests
- ✅ Perform code reviews and enforce best practices
- ✅ Debug and fix issues across the entire stack
- ✅ Ensure security best practices (XSS, SQL injection prevention, etc.)

**Deployment & DevOps:**
- ✅ Configure deployment pipelines (Netlify, Vercel, etc.)
- ✅ Manage environment variables across environments
- ✅ Handle build and deployment issues
- ✅ Monitor and optimize application performance

---

## 📋 What You (The User) Provide

**Credentials & Configuration:**
- Backend credentials in `.env` files (Supabase, Firebase, etc.)
- API keys for third-party services
- Any other service credentials needed

**Requirements & Direction:**
- Feature requests and functional requirements
- Design preferences and UI/UX feedback
- Business logic and domain knowledge
- Final approval on architectural decisions
- Clarifications when needed

---

## 🔄 Development Workflow

When you request a feature or bug fix, Claude Code will:

1. **Create a feature branch** (following git best practices)
2. **Implement the full solution:**
   - Backend (database, API, functions, RLS policies)
   - Frontend (UI, services, state management)
   - Testing (unit, widget, integration tests)
3. **Commit the changes** with descriptive messages
4. **Create a pull request** (if requested)
5. **Deploy and verify** the changes work correctly

**You stay in control** - Claude Code will ask clarifying questions when needed and always explain what's being built and why.

---

## 🌿 Git Workflow & Branch Strategy

### ⚠️ CRITICAL RULE: NEVER COMMIT DIRECTLY TO MAIN

**This is a mandatory practice for all development work. No exceptions.**

### Branch Strategy

#### Two Long-Lived Branches

```
main (production)     ← Stable releases for app store
  └── test (beta)     ← Beta testing with real users
        └── feature/* ← Development work
```

| Branch | Purpose | When to Use |
|--------|---------|-------------|
| `main` | Production releases | App store submissions, stable builds |
| `test` | Beta testing | Testing new features with real users |
| `feature/*` | Development | All new work starts here |

#### Branch Protection Rules
- **main** branch is **protected** and represents production-ready code
- **test** branch is for beta testing with real users
- All changes MUST go through feature branches
- Direct commits to main/test are **STRICTLY PROHIBITED**

#### Feature Branch Workflow

**1. Before Starting Any Work:**
```bash
# Always start from test branch (for beta testing)
git checkout test
git pull origin test

# Create a new feature branch
git checkout -b feature/your-feature-name
```

**2. Branch Naming Conventions:**

Use descriptive, kebab-case branch names with prefixes:

- `feature/` - New features or enhancements
  - Example: `feature/add-chat-interface`
  - Example: `feature/dashboard-investment-section`

- `fix/` - Bug fixes
  - Example: `fix/savings-rate-calculation`
  - Example: `fix/auth-redirect-loop`

- `refactor/` - Code refactoring (no functionality change)
  - Example: `refactor/supabase-service-structure`
  - Example: `refactor/dashboard-components`

- `docs/` - Documentation updates
  - Example: `docs/update-readme-setup-instructions`
  - Example: `docs/add-api-documentation`

- `test/` - Adding or updating tests
  - Example: `test/add-auth-integration-tests`
  - Example: `test/dashboard-unit-tests`

- `chore/` - Maintenance tasks, dependency updates
  - Example: `chore/update-dependencies`
  - Example: `chore/configure-ci-pipeline`

**3. During Development:**
```bash
# Make your changes and commit frequently
git add .
git commit -m "Descriptive commit message"

# Keep your branch up to date with main
git fetch origin
git rebase origin/main  # or merge if you prefer
```

**4. Before Creating Pull Request:**
```bash
# Ensure all tests pass
npm test  # or flutter test, pytest, etc.

# Ensure code is formatted
npm run format  # or flutter format, black, etc.

# Ensure no lint errors
npm run lint  # or flutter analyze, eslint, etc.

# Push your feature branch
git push origin feature/your-feature-name
```

**5. Pull Request Process:**
- Create PR from feature branch to main
- Fill out PR template with:
  - Description of changes
  - Related issue numbers
  - Testing performed
  - Screenshots (if UI changes)
- Request code review from team member(s)
- Address all review comments
- Ensure CI/CD checks pass
- Squash and merge (or rebase merge based on team preference)

**6. After Merge to Test:**
```bash
# Delete the feature branch locally
git checkout test
git pull origin test
git branch -d feature/your-feature-name

# Delete the remote branch (if not auto-deleted)
git push origin --delete feature/your-feature-name
```

**7. Promoting Test to Production:**

When beta testing is complete and features are stable:
```bash
# Merge test into main for production release
git checkout main
git pull origin main
git merge test
git push origin main

# Now build for app store release
flutter build apk --release
flutter build ios --release
```

### Commit Message Guidelines

Follow conventional commit format:

```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, no logic change)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```bash
feat: add AI chat interface with OpenRouter integration

fix: correct savings rate calculation for negative values

docs: update CHANGELOG for v1.1.0 release

refactor: extract dashboard metrics into separate components
```

### Emergency Hotfixes

Even for critical production bugs:
1. Create a `hotfix/` branch from main
2. Fix the issue
3. Create PR and get expedited review
4. Merge to main after approval
5. Deploy immediately

```bash
git checkout main
git pull origin main
git checkout -b hotfix/critical-auth-bug
# Fix the bug
git push origin hotfix/critical-auth-bug
# Create PR for expedited review
```

### Why This Matters

1. **Code Quality**: PRs enable peer review and catch bugs early
2. **Documentation**: PR descriptions document why changes were made
3. **Safety**: Protected main branch prevents accidental breaking changes
4. **Collaboration**: Team members can see what's being worked on
5. **Rollback**: Easy to revert individual features if needed
6. **CI/CD**: Automated testing runs on all PRs before merge
7. **History**: Clean, understandable git history

### Enforcement

- Configure branch protection rules on GitHub:
  - Require pull request reviews before merging
  - Require status checks to pass (tests, linting)
  - Require branches to be up to date before merging
  - Include administrators in these restrictions

---

## 🌳 Git Worktrees for Parallel Development

### Why Use Git Worktrees?

Git worktrees allow you to have multiple branches checked out simultaneously in different directories, enabling:
- **Parallel agent execution** - Run multiple Claude Code agents on different features simultaneously
- **Quick context switching** - Switch between features without stashing or committing incomplete work
- **Isolated testing** - Test different branches side-by-side without affecting your main working directory
- **Reduced merge conflicts** - Work on multiple features independently

### `.trees` Folder Structure

We use a dedicated `.trees` directory to organize all worktrees:

```
project-root/                    # Main repository
├── .git/                        # Git directory
├── src/                         # Your main working directory
├── .trees/                      # Worktrees directory (gitignored)
│   ├── feature-chat/           # Worktree for chat feature
│   ├── feature-dashboard/      # Worktree for dashboard feature
│   ├── fix-auth-bug/           # Worktree for bug fix
│   └── test-integration/       # Worktree for testing
└── ...
```

### Best Practices for Worktree Management

**1. Create a Dedicated Worktree for Each Feature:**

```bash
# Create a new feature branch and worktree in one command
git worktree add .trees/feature-chat -b feature/add-chat-interface

# For existing branches
git worktree add .trees/fix-auth fix/auth-redirect-loop
```

**2. List All Active Worktrees:**

```bash
# See all worktrees and their branches
git worktree list
```

**3. Working with Worktrees:**

```bash
# Navigate to a worktree
cd .trees/feature-chat

# Work normally - all git commands work as usual
git status
git add .
git commit -m "feat: add chat interface"
git push origin feature/add-chat-interface

# Return to main directory
cd ../..
```

**4. Clean Up After Merging:**

```bash
# Remove a worktree when feature is merged
git worktree remove .trees/feature-chat

# Or if you're in the main directory
rm -rf .trees/feature-chat
git worktree prune  # Clean up metadata
```

**5. Running Multiple Agents:**

To run multiple Claude Code agents simultaneously:

```bash
# Terminal 1 - Working on chat feature
cd .trees/feature-chat
# Start Claude Code agent here

# Terminal 2 - Working on dashboard
cd .trees/feature-dashboard
# Start another Claude Code agent here

# Terminal 3 - Main development
cd /path/to/project
# Continue working in main directory
```

### Worktree Workflow Example

**Scenario**: You need to work on authentication while also implementing the dashboard, and fix a critical bug.

```bash
# Start from main repository
cd /path/to/project

# Create worktree for dashboard feature
git worktree add .trees/dashboard -b feature/dashboard-section

# Create worktree for authentication
git worktree add .trees/auth -b feature/auth-flow

# Create worktree for urgent bug fix
git worktree add .trees/hotfix -b hotfix/critical-bug

# Now you have 3 separate workspaces
# Open separate terminals/sessions for each
```

### Important Notes

**Gitignore Configuration:**

Add `.trees/` to your `.gitignore` to prevent accidentally committing worktree directories:

```gitignore
# Git worktrees
.trees/
```

**Shared Git Objects:**

All worktrees share the same `.git` directory, meaning:
- ✅ Commits in one worktree are immediately visible to others
- ✅ No duplication of repository data (saves disk space)
- ✅ `git fetch` in any worktree updates all worktrees
- ⚠️ Cannot checkout the same branch in multiple worktrees simultaneously

**Cleanup Best Practices:**

```bash
# Before removing a worktree, ensure changes are committed or pushed
cd .trees/feature-chat
git status  # Make sure working directory is clean

# Return to main directory
cd ../..

# Remove the worktree
git worktree remove .trees/feature-chat

# Periodically clean up stale worktree references
git worktree prune
```

**Naming Conventions:**

Keep worktree directory names aligned with branch names for clarity:
- Branch: `feature/add-chat-interface` → Worktree: `.trees/chat` or `.trees/feature-chat`
- Branch: `fix/auth-redirect-loop` → Worktree: `.trees/fix-auth` or `.trees/auth-fix`
- Branch: `hotfix/critical-bug` → Worktree: `.trees/hotfix`

### Benefits for Multi-Agent Development

When running multiple Claude Code agents:

1. **Isolation**: Each agent works in its own worktree without interfering with others
2. **Parallel Progress**: Multiple features can be developed simultaneously
3. **Independent Testing**: Test each feature in isolation before integration
4. **Clean Context**: Each agent has a clean working directory for its specific task
5. **Easy Comparison**: Compare implementations side-by-side across worktrees

### Worktree Commands Quick Reference

```bash
# Create new worktree with new branch
git worktree add .trees/<name> -b <branch-name>

# Create worktree from existing branch
git worktree add .trees/<name> <existing-branch>

# List all worktrees
git worktree list

# Remove a worktree (from main directory)
git worktree remove .trees/<name>

# Remove a worktree (forcefully if needed)
git worktree remove --force .trees/<name>

# Clean up worktree administrative files
git worktree prune

# Lock a worktree (prevent automatic pruning)
git worktree lock .trees/<name>

# Unlock a worktree
git worktree unlock .trees/<name>
```

---

## 🧪 Testing Strategy

### Unit Tests
- Test individual functions and methods in isolation
- Mock external dependencies
- Cover edge cases and error conditions
- Test pure business logic

### Integration Tests
- Test how different parts of the system work together
- Test API endpoints
- Test database operations
- Test authentication flows

### End-to-End (E2E) Tests
- Test complete user flows
- Simulate real user interactions
- Test critical paths (registration, login, core features)
- Test across different devices/browsers

### Performance Tests
- Load time optimization
- Large dataset handling
- Real-time update latency
- Memory usage profiling

---

## 🔐 Security Best Practices

### Data Protection
1. **Encryption at Rest**: Encrypt sensitive data in database
2. **Encryption in Transit**: Use HTTPS/TLS for all API communications
3. **Row-Level Security**: Users can only access their own data
4. **JWT Tokens**: Secure authentication with automatic refresh

### API Security
1. **Environment Variables**: API keys stored securely, never in code
2. **Rate Limiting**: Prevent abuse of APIs
3. **Input Validation**: All user inputs sanitized and validated
4. **CORS Configuration**: Restrict API access to authorized domains

### Privacy Compliance
1. **GDPR**: Data export and deletion capabilities
2. **Data Minimization**: Only collect necessary information
3. **Consent Management**: Clear user consent for data collection
4. **Audit Logs**: Track all data access and modifications

---

## ✅ Definition of Done (DoD)

For each feature to be considered complete:

1. ✅ **Functionality**: All acceptance criteria met
2. ✅ **Testing**: Unit tests, widget tests, and integration tests pass
3. ✅ **UI/UX**: Matches design specifications, responsive on all screen sizes
4. ✅ **Accessibility**: Screen reader support, color contrast compliance
5. ✅ **Performance**: No lag, smooth animations, optimized queries
6. ✅ **Security**: Input validation, XSS prevention, secure API calls
7. ✅ **Documentation**: Code comments, API docs, user-facing help text
8. ✅ **Review**: Code review completed, feedback addressed
9. ✅ **Deployment**: Successfully deployed to staging/production

---

## 🎯 Core Development Principles

### 1. Data Integrity First
- Never assume or fabricate data
- Always validate before saving to database
- Provide clear audit trails for all changes
- Implement rollback mechanisms for user errors

### 2. Real-time Sync
- Use real-time services (Supabase Realtime, Firebase, etc.) for instant updates
- Implement optimistic UI updates for perceived speed
- Handle conflicts gracefully with user control
- Maintain consistency across all screens

### 3. User Empowerment
- Give users full control over their data
- Provide clear explanations for automated actions
- Allow manual overrides for all automated calculations
- Maintain transparency in all operations

### 4. Performance & Scalability
- Lazy load data and resources
- Implement pagination for large datasets
- Cache frequently accessed data
- Optimize database queries with proper indexing

---

## 📝 Documentation Maintenance

### Architecture Updates
**IMPORTANT:** After every successful feature implementation or significant change:

1. **Update `architecture.md`** with:
   - Mark completed phases/features as done
   - Update the "Current Status" section
   - Add any new implementation details
   - Document new files created or modified
   - Update the roadmap with next steps

2. **Commit the documentation** along with code changes

This ensures the architecture document always reflects the current state of the project and provides accurate guidance for future development.
