# Writing Style

This repository is early, practical, and MATLAB-dependent. The docs should
sound like a maintainer helping someone get one figure rendered, not like a
product launch page.

## Short Rules

### Write like a maintainer

Use the voice of someone who has run the command, seen the failure mode, and is
trying to save the next person a few minutes. Plain sentences are fine. A small
warning is better than a broad promise.

Good:

```text
Run the metadata commands first. They catch checkout and catalog problems
before MATLAB starts.
```

Less useful:

```text
This workflow transforms the MATLAB plotting experience with powerful automation.
```

### Say what works today

Describe the current support level. If a scheme is only cataloged, say that. If
GitHub Actions cannot render MATLAB figures, say that too. Do not turn roadmap
items into present-tense features.

### Do not claim adoption

Until there is public evidence, do not claim downloads, broad usage, external
approval, or program eligibility. Use reproducible evidence instead: commit,
workflow run, command, rendered output, issue link, or report summary.

### Prefer one concrete command

When a paragraph feels vague, replace part of it with the exact command a user
can run next. The first-use path should always make it clear whether MATLAB is
needed.

### Keep Chinese docs conversational

Chinese docs should not be literal translations. Keep them natural and direct:

- use "先检查", "再渲染", and "如果失败" style wording;
- keep long setup explanations split into short paragraphs;
- avoid slogans such as "赋能", "行业领先", or "一站式";
- name real boundaries, especially MATLAB CLI, private data, and clean-room
  source handling.

## Review Checklist

Before merging README, walkthrough, or Skill wording changes, check:

- The text says what the repository can do today.
- The text names the MATLAB/no-MATLAB boundary.
- Claims about users, adoption, or external programs are backed by public
  evidence or removed.
- At least one next command is visible near the explanation.
- Chinese and English docs match in meaning, but neither side reads like a
  machine translation.
