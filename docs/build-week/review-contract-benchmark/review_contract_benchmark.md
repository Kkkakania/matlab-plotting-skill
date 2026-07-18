# Review Contract Adversarial Benchmark

**15/15 checks passed; 14 adversarial outputs failed closed.**

| Case | Expected | Observed | Result |
| --- | --- | --- | --- |
| `valid_control` | accept | accept | PASS |
| `unknown_action` | reject | reject | PASS |
| `action_value_injection` | reject | reject | PASS |
| `unknown_candidate` | reject | reject | PASS |
| `unknown_model` | reject | reject | PASS |
| `wrong_surface` | reject | reject | PASS |
| `unknown_top_level_field` | reject | reject | PASS |
| `missing_summary` | reject | reject | PASS |
| `score_out_of_range` | reject | reject | PASS |
| `boolean_score` | reject | reject | PASS |
| `duplicate_action` | reject | reject | PASS |
| `accept_with_actions` | reject | reject | PASS |
| `repair_without_actions` | reject | reject | PASS |
| `too_many_findings` | reject | reject | PASS |
| `malformed_json` | reject | reject | PASS |

The control is a checked GPT-5.6 review fixture. Adversarial cases mutate that fixture
at the model-to-MATLAB boundary; no model-authored code is executed.
