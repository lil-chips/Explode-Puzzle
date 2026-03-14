# Learnings Log

Captured learnings, corrections, and discoveries. Review before major tasks.

---

## [LRN-20260314-001] correction

**Logged**: 2026-03-14T14:06:00+11:00
**Priority**: medium
**Status**: pending
**Area**: docs

### Summary
When editing Word documents programmatically, verify section placement after writing; content can end up appended under the wrong heading even if the file saves successfully.

### Details
While updating Cloud Security Assignment1_Draft.docx, Q1 content was appended after the Q3 heading instead of directly under the Q1 heading. The user caught the layout mistake from the rendered document. For generated .docx files, a post-write structural check is needed, not just a save/commit.

### Suggested Action
After each .docx modification, inspect paragraph order (or reopen the file and verify heading adjacency) before telling the user the section is complete.

### Metadata
- Source: user_feedback
- Related Files: School/CloudSecurity/Assignment1_Draft.docx
- Tags: docx, verification, section-order

---
