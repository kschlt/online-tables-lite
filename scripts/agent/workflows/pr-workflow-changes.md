# PR Workflow Changes: As-Is vs To-Be

## Key Philosophy Change
**From**: Heavy promptlet-based agent interaction
**To**: Direct automation with clear terminal stops for user intervention

## Specific Changes

### 1. Protected Branch Handling
**As-Is**: Generate `branch_protection_error` promptlet → Claude creates branch → retry workflow
**To-Be**: **STOP** with terminal message: "❌ Cannot create PR from main/production - USER ACTION REQUIRED"
**Rationale**: Protected branch issues require user decision, not automation

### 2. Merge Conflicts
**As-Is**: Generate `conflict_resolution` promptlet → Claude rebases → retry workflow
**To-Be**: **STOP** with terminal message: "⚠️ Merge conflicts detected - Rebase required before PR - USER ACTION REQUIRED"
**Rationale**: Conflict resolution needs user review of changes

### 3. No Changes (0 commits ahead)
**As-Is**: Generate `no_changes` promptlet → Claude understands no PR needed
**To-Be**: **STOP** with terminal message: "ℹ️ No changes to create PR - 0 commits ahead of main - WORKFLOW COMPLETE"
**Rationale**: No promptlet needed for simple status message

### 4. Uncommitted Changes
**As-Is**: Generate `validation_warning` promptlet → Claude commits first → retry workflow
**To-Be**: **DIRECT AUTOMATION**: Execute `make commit` with `--return-to=pr-workflow` flag
**Rationale**: Committing staged changes can be automated safely

### 5. PR Description Generation
**As-Is**: Red promptlet (suggests manual intervention needed)
**To-Be**: Green automation (direct processing without promptlet)
**Rationale**: PR description generation is pure automation, no user input needed

## Implementation Requirements

### 1. Modify `validate_changes()` function
- Remove promptlet generation for stop conditions
- Add direct terminal messages with clear user action guidance
- Implement direct `make commit` call for uncommitted changes

### 2. Update commit workflow
- Add `--return-to=pr-workflow` parameter support
- Ensure commit workflow returns to PR workflow after completion

### 3. Streamline PR body generation
- Remove promptlet step
- Direct automation from git-cliff data to PR creation

### 4. Color coding updates
- Stop conditions: Red (user action required)
- Automation steps: Green (no user intervention)
- Process steps: Light green (system execution)

## Benefits
1. **Clearer user experience**: Know exactly when user action is needed
2. **Faster automation**: Fewer ping-pong interactions with agent
3. **Better error handling**: Clear terminal messages instead of hidden promptlets
4. **Logical flow**: Automation where safe, stops where user decision needed