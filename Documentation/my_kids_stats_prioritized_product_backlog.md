# MyKidsStats – Prioritized Product Backlog

This backlog consolidates all identified user stories into a **prioritized, clean product backlog** aligned with the current architecture and UI/UX specifications. Stories are grouped by **Epic**, ordered by **priority**, and include **clear acceptance criteria**.

---

## Priority Legend
- **P0 – Core / MVP (Must Have)**
- **P1 – High Value (Should Have)**
- **P2 – Enhancement (Nice to Have / Phase 2)**

---

# EPIC 1: Live Game Stat Tracking (Core Value)

## P0 – Track detailed stats for my child during a game
**User Story**  
As a parent, I want to track detailed basketball stats for my child so that I can accurately record their game performance.

**Acceptance Criteria**
- I can record:
  - 3PT made / missed
  - 2PT made / missed
  - FT made / missed
  - Rebounds, Assists, Steals, Blocks
- Stats update immediately when tapped
- Stats are associated with the active game and child
- Stats persist if the app is backgrounded or closed

---

## P0 – Update stats in real time with simple controls
**User Story**  
As a parent, I need to update stats in real time using clear, simple controls so that I don’t miss plays during the game.

**Acceptance Criteria**
- Buttons are large and easy to tap with one hand
- Each tap provides immediate visual feedback
- Stat entry takes no more than one tap per action
- App remains responsive under rapid input

---

## P0 – Undo or correct stat entries
**User Story**  
As a parent, I want to undo or correct stat entries so that mistakes during fast gameplay do not permanently affect stats.

**Acceptance Criteria**
- I can undo the most recent stat entry
- I can delete or edit an incorrect stat entry
- Undo does not corrupt other stats
- Corrections are reflected immediately in summaries

---

# EPIC 2: Game Lifecycle Management

## P0 – Manage game lifecycle (start and end)
**User Story**  
As a parent, I want to start, and end a game so that stats are tied to the correct game session.

**Acceptance Criteria**
- I can explicitly start a new game
- I can end a game and mark it as final
- Ended games are read-only by default

---

## P0 – Manage game lifecycle (Automatic end)
**User Story**  
As a parent, I want to automatically end a game if 3 hours has elapsed from the start time or the application is killed so that stats are tied to the correct game session.

**Acceptance Criteria**
- I can explicitly start a new game
- I can end a game and mark it as final
- Ended games are read-only by default

---

## P0 – Track opponent score and game result
**User Story**  
As a parent, I want to track opponent points so that wins and losses are recorded accurately.

**Acceptance Criteria**
- I can increment/decrement opponent score
- Final score is visible in game summary
- Win/loss is automatically calculated

---

# EPIC 3: Team & Roster Management

## P0 – Create and manage teams by season
**User Story**  
As a parent, I want to create one or more teams for my child so that I can track performance by team and season.

**Acceptance Criteria**
- I can create, edit, and delete teams
- Each team has a name and season identifier
- Games are associated with a team

---

## P0 – Add and remove players from a team
**User Story**  
As a parent, I want to add or remove players from a team so that I can manage rosters accurately.

**Acceptance Criteria**
- I can add players to a team roster
- I can remove players from a roster
- Roster changes do not affect past games

---

## P1 – Track points only for other players
**User Story**  
As a parent, I want to track only the points of other players so that I can focus on my child’s full stat line.

**Acceptance Criteria**
- Other players have point-only controls
- Their points appear in game summaries
- No advanced stats are required for them

---

# EPIC 4: Child & Family Management

## P0 – Manage multiple children
**User Story**  
As a parent, I want to manage stats for multiple children so that I can track all my kids in one app.

**Acceptance Criteria**
- I can add, edit, and delete children
- Each child has independent teams and stats
- I can switch the active child

---

## P1 – Switch focus child during a game
**User Story**  
As a parent, I want to switch which child is the focus during a game so that I can track siblings on the same team.

**Acceptance Criteria**
- I can change the focus child mid-game
- Stats are attributed to the correct child
- UI clearly indicates the active focus child

---

# EPIC 5: Game Review & Insights

## P0 – View game highlight summary
**User Story**  
As a parent, I want to see a clear game summary so that I can quickly understand performance after the game.

**Acceptance Criteria**
- My child’s full stat line is displayed
- Shooting percentages are calculated
- Other players’ points are listed
- Opponent score and result are shown

---

## P1 – Compare game to season averages
**User Story**  
As a parent, I want to compare a game’s stats to season averages so that I can see performance context.

**Acceptance Criteria**
- Season averages are displayed
- Game stats are visually compared to averages

---

## P2 – View performance trends over time
**User Story**  
As a parent, I want to see performance trends so that I can understand improvement over time.

**Acceptance Criteria**
- Trends are available for key stats
- Data spans games, seasons, and career

---

# EPIC 6: Career & Season Aggregation

## P0 – View season stats
**User Story**  
As a parent, I want to view season stats so that I can understand performance across a season.

**Acceptance Criteria**
- Season totals and averages are calculated
- Stats include all games in the season

---

## P0 – View career stats
**User Story**  
As a parent, I want to view career stats so that I can see long-term performance.

**Acceptance Criteria**
- Career stats aggregate across teams/seasons
- Career view is read-only

---

# EPIC 7: Sharing & Export

## P0 – Text game highlights
**User Story**  
As a parent, I want to text game highlights so that family can see my child’s performance.

**Acceptance Criteria**
- A formatted summary can be shared
- Uses native share/text options

---

## P1 – Control what stats are shared
**User Story**  
As a parent, I want to choose which stats are shared so that I can control what others see.

**Acceptance Criteria**
- I can toggle stats before sharing
- Preview is shown before sending

---

## P0 – Export game stats as CSV
**User Story**  
As a parent, I want to export game stats as CSV so that I can store or analyze them externally.

**Acceptance Criteria**
- CSV includes all recorded game stats
- File can be saved or shared

---

## P1 – Export season stats as CSV
**User Story**  
As a parent, I want to export season stats as CSV so that I can archive a full season.

**Acceptance Criteria**
- CSV aggregates season data correctly
- One row per game or per season summary

---

## P1 – Export team stats as CSV
**User Story**  
As a parent, I want to export team stats as CSV so that I can share summaries with others.

**Acceptance Criteria**
- CSV includes team totals and record

---

## P1 – Export career stats as CSV
**User Story**  
As a parent, I want to export career stats as CSV so that I permanently own the data.

**Acceptance Criteria**
- CSV aggregates across all seasons and teams

---

# EPIC 8: Data Safety & Reliability

## P0 – Prevent accidental data loss
**User Story**  
As a parent, I want confirmation before deleting data so that I don’t lose stats accidentally.

**Acceptance Criteria**
- Confirmation dialog appears before delete
- Deleted items are clearly identified

---

## P0 – Offline-first gameplay
**User Story**  
As a parent, I want the app to work offline so that stats are never lost in gyms without service.

**Acceptance Criteria**
- All stat tracking works without internet
- Data syncs automatically when online

---

## P1 – View play-by-play stat log
**User Story**  
As a parent, I want to view a chronological stat log so that I can validate recorded stats.

**Acceptance Criteria**
- Stat events are listed in time order
- Entries can be edited or deleted

---

# EPIC 9: Quality of Life Enhancements

## P2 – Add game notes
**User Story**  
As a parent, I want to add notes to a game so that stats have context later.

**Acceptance Criteria**
- Notes are editable
- Notes appear in game summary

---

## P2 – Assign jersey numbers or nicknames
**User Story**  
As a parent, I want to assign jersey numbers or nicknames so that players are easy to identify.

**Acceptance Criteria**
- Nickname/number appears in roster and game views

---

# EPIC 10: Non-Functional Requirements (System Qualities)

Non-functional requirements define **how well** the system must work. These apply across all features and are considered **P0 unless otherwise noted**.

---

## NFR-1: Performance & Responsiveness (P0)
**Requirement**  
The app must respond fast enough to support real-time stat tracking during live games.

**Acceptance Criteria**
- Stat entry actions register visually within **<100 ms**
- No perceptible lag during rapid, repeated stat entry
- UI remains responsive with at least **100 stat events per game**
- App maintains stable performance on mid-range iOS devices

---

## NFR-2: Offline-First Reliability (P0)
**Requirement**  
The app must function fully without an internet connection during games.

**Acceptance Criteria**
- All stat tracking works with no network connection
- No data loss occurs if the app is closed while offline
- Data automatically syncs when connectivity is restored
- Sync conflicts are resolved deterministically without user intervention

---

## NFR-3: Data Integrity & Accuracy (P0)
**Requirement**  
Recorded stats must be accurate, consistent, and auditable.

**Acceptance Criteria**
- Every stat entry is stored as a timestamped event
- Aggregate stats are derived from underlying events
- Editing or deleting events updates all derived stats correctly
- No duplicate stat events are created accidentally

---

## NFR-4: Usability & Accessibility (P0)
**Requirement**  
The app must be usable in noisy, fast-paced gym environments.

**Acceptance Criteria**
- All primary actions are reachable within one tap
- Buttons meet minimum touch target guidelines
- High-contrast visuals for readability in poor lighting
- App supports system text size scaling

---

## NFR-5: Error Prevention & Recovery (P0)
**Requirement**  
The system must minimize user errors and support easy recovery.

**Acceptance Criteria**
- Destructive actions require confirmation
- Undo is available for recent stat entries
- App recovers gracefully from crashes without data loss

---

## NFR-6: Scalability (P1)
**Requirement**  
The app must support long-term use across many seasons and games.

**Acceptance Criteria**
- Supports at least **1,000 games per child** without performance degradation
- Career stat calculations remain performant
- Storage growth is handled efficiently

---

## NFR-7: Security & Privacy (P0)
**Requirement**  
User data must remain private and secure.

**Acceptance Criteria**
- All data stored locally is sandboxed per OS guidelines
- No data is shared externally without explicit user action
- Exported files contain only selected data

---

## NFR-8: Data Portability & Ownership (P0)
**Requirement**  
Users must retain ownership and control of their data.

**Acceptance Criteria**
- All stats can be exported in CSV format
- Exported data is human-readable and well-labeled
- No proprietary lock-in prevents data extraction

---

## NFR-9: Maintainability & Extensibility (P1)
**Requirement**  
The system must be easy to extend with new sports or stats.

**Acceptance Criteria**
- Stat types are enum- or config-driven
- Adding a new stat does not require schema redesign
- Core stat engine is sport-agnostic

---

## NFR-10: Platform Compatibility (P0)
**Requirement**  
The app must behave consistently across supported devices.

**Acceptance Criteria**
- Fully supported on current and previous major iOS versions
- Works on both phone and tablet form factors
- Handles orientation changes without data loss

---

# Non-Functional Requirements (NFRs)

These requirements define the quality attributes for MyKidsStats. They apply across all epics and user stories.

## NFR-1: Performance & Responsiveness
- **Live stat entry latency:** Each stat tap updates UI feedback in **≤ 100 ms** (target **≤ 50 ms**).
- **Cold start time:** App becomes usable in **≤ 3 seconds** on a mid-tier device.
- **Navigation latency:** Screen transitions complete in **≤ 300 ms** under normal conditions.
- **Bulk rendering:** Team lists, game lists, and stat logs remain smooth (no visible stutter) up to **200 games** and **20 players/team**.

## NFR-2: Offline-First Reliability
- **Offline operation:** All live game functions (stat entry, undo, score tracking, game end) work with **no internet**.
- **Durable writes:** Stat events are persisted locally within **≤ 1 second** of entry.
- **Recovery:** If the app is killed or the phone reboots, the active game can be resumed without loss of recorded events.

## NFR-3: Data Integrity & Correctness
- **Event sourcing:** All aggregates (points, FG%, season/career totals) must be reproducible from stored stat events.
- **Idempotency:** Replaying sync operations must not duplicate stat events or inflate totals.
- **Consistency:** Game summary totals must always match the underlying event log.
- **Time ordering:** Each stat event has a timestamp; ordering is stable and deterministic.

## NFR-4: Sync & Conflict Handling (If Cloud Sync Enabled)
- **Sync timing:** When connectivity is available, local changes sync automatically within **≤ 60 seconds**.
- **Conflict policy:** If two devices edit the same game, the app must:
  - Preserve all non-conflicting events, and
  - Surface a clear resolution UI for conflicting edits (or apply last-write-wins with an audit trail).
- **Transparency:** Sync status is visible (e.g., “Synced”, “Syncing…”, “Offline”).

## NFR-5: Usability (Real-Time Game Context)
- **One-handed operation:** Primary live-game actions reachable with one thumb on common phone sizes.
- **Tap safety:** Controls prevent common mis-taps (spacing, confirmation for destructive actions).
- **Low cognitive load:** Recording a made/missed shot requires **no more than 2 taps** total.
- **Accessibility:** Supports Dynamic Type / system font scaling without truncating critical numbers.

## NFR-6: Accessibility & Inclusivity
- **Screen reader support:** Key live-game controls and stat values have accessible labels.
- **Color independence:** Important distinctions (focus child vs team) cannot rely on color alone.
- **Touch targets:** Minimum target size **44x44 pt**.

## NFR-7: Security & Privacy
- **Local data protection:** Stored data uses platform-standard protection (e.g., iOS Data Protection / encrypted storage where applicable).
- **PII minimization:** Only store what is necessary (child name, optional photo, DOB optional).
- **Sharing controls:** Export/share flows must not expose unintended data (e.g., other children’s stats) by default.

## NFR-8: Export Quality (CSV)
- **Deterministic format:** CSV columns and ordering are consistent across exports.
- **Completeness:** Export includes sufficient identifiers (child, team, season, game date, opponent) to be usable in Excel.
- **Validation:** Exported totals match in-app totals for the same scope.

## NFR-9: Maintainability & Observability
- **Logging:** Key actions (start/end game, export, sync failures) are logged for troubleshooting (without storing sensitive content).
- **Error handling:** User-facing errors are actionable and human-readable.
- **Testability:** Core stat aggregation and CSV export logic has automated tests covering common and edge cases.

## NFR-10: Scalability Limits (Supported)
- Support at least:
  - **10 children**
  - **50 teams total**
  - **500 games total**
  - **20 players per team**
  - **50,000 stat events** without degraded usability.

## NFR-11: Compatibility
- **iOS:** Supports current iOS major version and **two prior** (unless business constraints specify otherwise).
- **Device support:** Works on common phone screen sizes; tablet support optional unless explicitly in scope.

## End of Backlog

