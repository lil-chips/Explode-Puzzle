# problem-solving.md — Structured Problem Solving Playbook

This playbook defines how to approach and solve complex problems.

The goal is to move from confusion to clarity through structured reasoning.

Avoid random trial-and-error thinking.

Prefer systematic analysis.

---

# Core Principle

Good problem solving follows a structured process:

1. understand the problem
2. identify constraints
3. break the system into components
4. find root causes
5. design possible solutions
6. test solutions
7. refine based on results

Focus on understanding before acting.

---

# Step 1 — Define the Problem

Clearly describe the problem.

Questions:

- What exactly is the issue?
- What outcome is expected?
- What is currently happening instead?

Avoid vague definitions.

Example:

Bad definition:
"The system isn't working."

Better definition:
"The API request returns a timeout after 30 seconds."

Output:

- precise problem statement
- expected vs actual behavior

---

# Step 2 — Understand the System

Understand how the system works before trying to fix it.

Questions:

- What components are involved?
- How does data flow through the system?
- Where could failure occur?

Map the system:

input → process → output

Output:

- system overview
- key components
- interaction points

---

# Step 3 — Identify Constraints

Every problem exists within constraints.

Examples:

- time constraints
- technical limitations
- budget limits
- regulatory restrictions
- system dependencies

Questions:

- What cannot change?
- What resources are available?

Output:

- constraint list
- resource availability

---

# Step 4 — Break the Problem Into Components

Large problems are easier to solve when broken into smaller parts.

Questions:

- Which components may be responsible?
- Which areas are unlikely to be the cause?

Example structure:

Component A  
Component B  
Component C  

Output:

- problem decomposition
- suspected areas

---

# Step 5 — Root Cause Analysis

Focus on the underlying cause, not symptoms.

Methods:

- "5 Whys"
- system tracing
- dependency mapping

Questions:

- Why is this happening?
- What condition triggered it?
- What changed recently?

Avoid fixing symptoms while ignoring root causes.

Output:

- most probable root causes
- supporting evidence

---

# Step 6 — Generate Possible Solutions

Brainstorm potential solutions.

Questions:

- What are the simplest fixes?
- What are more robust long-term solutions?

Examples:

- configuration fix
- code change
- architecture redesign
- process improvement

Output:

- list of possible solutions
- complexity level

---

# Step 7 — Evaluate Solutions

Compare solutions based on key criteria:

- effectiveness
- complexity
- cost
- risk
- reversibility

Questions:

- Which solution solves the root cause?
- Which solution introduces minimal risk?

Output:

- ranked solution options

---

# Step 8 — Implement the Best Solution

Apply the chosen solution carefully.

Steps:

1. implement changes
2. monitor results
3. verify problem resolution

If possible:

- test in safe environment
- roll out gradually

Output:

- implementation steps
- validation results

---

# Step 9 — Validate the Outcome

Confirm the problem is actually solved.

Questions:

- Did the expected outcome occur?
- Are side effects introduced?
- Does the system behave correctly now?

Output:

- verification results
- new observations

---

# Step 10 — Document the Solution

Document lessons learned.

Record:

- root cause
- solution implemented
- prevention measures

This improves future problem solving.

Output:

- documented insight
- future prevention strategy

---

# Common Problem-Solving Mistakes

Avoid these traps:

### Jumping to Solutions

Trying fixes before understanding the problem.

### Treating Symptoms Instead of Causes

Fixing visible issues without addressing root causes.

### Overcomplicating Solutions

Choosing complex solutions when simple ones work.

### Ignoring System Interactions

Forgetting that systems have interconnected components.

---

# First Principles Thinking

When facing unfamiliar problems:

Break the problem down to fundamental truths.

Ask:

- what must be true?
- what assumptions exist?
- what constraints are fundamental?

Rebuild solutions from basic principles.

---

# When to Use This Playbook

Use this framework when:

- debugging code
- diagnosing system failures
- solving engineering problems
- analyzing business challenges
- investigating unexpected outcomes

---

# Final Principle

Complex problems rarely have simple explanations.

Clarity comes from structured thinking.

The goal is not to guess the answer.

The goal is to **understand the system deeply enough that the solution becomes obvious.**
