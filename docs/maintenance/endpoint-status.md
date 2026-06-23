# TestRail API Endpoints - Testing Status

> **Maintenance snapshot:** this file is for verification history and live-environment notes. It is not part of the recommended runtime doc path for agents.

Tracked TestRail API v2 endpoints with testing status for this skill.

Legend:
- ✅ **TESTED & WORKING** - Verified in production
- 🔒 **PERMISSION-GATED** - Endpoint behavior depends on account privileges
- ⚠️ **SCRIPT EXISTS** - Script created but not fully tested
- 📝 **NOT TESTED** - Documented but no script yet
- ❌ **KNOWN ISSUES** - Tested but has problems

---

## Projects

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_projects` | GET | ✅ **TESTED & WORKING** | `scripts/get_projects.sh` | Verified with the currently authenticated account; accessible projects may change over time. |
| `/get_project/:id` | GET | ✅ **TESTED & WORKING** | `scripts/get_project.sh` | Verified project 1; returns a project object directly (`id=1`, `name="Sample Project"`). |

---

## Suites & Sections

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_suites/:project_id` | GET | ✅ **TESTED & WORKING** | Manual test | Found Suite 1: "Master" |
| `/get_sections/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_sections.sh` | Verified `project=1`, `suite=1`; response wraps 13 sections in `.sections`. |

---

## Test Cases

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_cases/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_cases.sh` | Returns a paginated case response; use `scripts/count_cases.sh` for live totals and `scripts/import_cases.sh` for paginated exports. |
| `/get_case/:id` | GET | ✅ **TESTED & WORKING** | `scripts/get_case.sh` | Verified case 1; returns a case object directly (`template_id=4`, `type_id=6`, `priority_id=2`). |
| `/add_case/:section_id` | POST | ✅ **TESTED & WORKING** | `examples/create_case.sh` | Created disposable case with template 2 + `custom_steps_separated`, then cleaned it up |
| `/update_case/:id` | POST | ✅ **TESTED & WORKING** | `scripts/update_case.sh` | Updated a disposable case title + `priority_id=4`, verified via `get_case`, then removed the fixture with `delete_case`. |

---

## Test Runs & Tests

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_runs/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_runs.sh` | Verified project 1; response is paginated with a `.runs` array and standard pagination fields. |
| `/add_run/:project_id` | POST | ✅ **TESTED & WORKING** | `scripts/create_run.sh` | Created run ID 14, 15, 16, 17 successfully |
| `/get_tests/:run_id` | GET | ✅ **TESTED & WORKING** | Used in `workflow_ci.sh` | Returns test IDs: [111, 112, 113] for run 15 |
| `/get_test/:id` | GET | ✅ **TESTED & WORKING** | `scripts/get_test.sh` | Verified on both executed and untested test instances; returns a test object directly with `run_id`, `case_id`, and `status_id`. |
| `/close_run/:run_id` | POST | ✅ **TESTED & WORKING** | `scripts/close_run.sh` | Closed run 17, marked is_completed=true |
| `/update_run/:id` | POST | ✅ **TESTED & WORKING** | `scripts/update_run.sh` | Updated an open disposable run name/description, verified via response body and `get_runs`, then deleted the run fixture. |
| `/delete_run/:id` | POST | ✅ **TESTED & WORKING** | Manual test | Deleted open disposable run 22; deleting completed runs returned HTTP 403 with current permissions |

---

## Results

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/add_result/:test_id` | POST | ✅ **TESTED & WORKING** | `scripts/add_result.sh` | Added result ID 99 to disposable test 132 and verified it via result queries |
| `/add_result_for_case/:run_id/:case_id` | POST | ✅ **TESTED & WORKING** | `scripts/add_result_for_case.sh` | Added result ID 104 for disposable run 54 / case 1, verified through `get_results_for_case` and `get_results_for_run`, then deleted the run fixture. |
| `/add_results/:run_id` | POST | ✅ **TESTED & WORKING** | `scripts/bulk_results.sh` | Added 3 results in workflow: 2 passed, 1 failed |
| `/get_results/:test_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_results.sh` | Verified against both executed (`size>0`) and unexecuted (`size=0`) tests; empty `.results` is expected missing-data behavior. |
| `/get_results_for_case/:run_id/:case_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_results_for_case.sh` | Verified against a completed run with recorded results; returns a paginated object with `.results`. |
| `/get_results_for_run/:run_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_results_for_run.sh` | Verified on runs with results and on runs with none; empty `.results` is expected when a run has no recorded results. |

---

## Plans

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_plans/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_plans.sh`, `examples/workflow_plans_milestones.sh` | Returns project plans; workflow verified disposable plan appears before cleanup and disappears after `delete_plan` |
| `/get_plan/:id` | GET | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Retrieved disposable plan with entry IDs and generated run IDs |
| `/add_plan/:project_id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Created disposable plan with an initial entry and disposable naming for cleanup |
| `/add_plan_entry/:plan_id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Added second disposable entry; API created a generated run for the new entry |
| `/update_plan/:id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Renamed disposable plan and updated description successfully |
| `/update_plan_entry/:plan_id/:entry_id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Renamed second entry and narrowed selected cases; verified via `get_tests` because generated-run `case_ids` were `null` in plan responses |
| `/close_plan/:id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Closed disposable plan and observed `is_completed=true`; later cleanup of that completed fixture was blocked with HTTP 403 on this server/user |
| `/delete_plan/:id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Deleted a separate disposable **unclosed** plan successfully; deleting a completed plan returned HTTP 403 `insufficient permissions` |

---

## Milestones

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_milestones/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_milestones.sh`, `examples/workflow_plans_milestones.sh` | Returns project milestones; workflow verified disposable milestone appears before cleanup and disappears after `delete_milestone` |
| `/get_milestone/:id` | GET | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Retrieved disposable milestone immediately after create/update |
| `/add_milestone/:project_id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Created disposable milestone used to verify linked-plan lifecycle |
| `/update_milestone/:id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Updated description and refs on disposable milestone successfully |
| `/delete_milestone/:id` | POST | ✅ **TESTED & WORKING** | `examples/workflow_plans_milestones.sh` | Deleted disposable milestone after plan cleanup; absence verified with `get_milestones` |

---

## Metadata & Configuration

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_users` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh users` | Admin-only per API docs; current account has access. Response is paginated with a `.users` array. |
| `/get_user/:id` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh user 1` | Verified user 1; returns a user object directly. |
| `/get_user_by_email` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh user_by_email EMAIL` | Verified with the authenticated account email from `.env`; returns a user object directly. |
| `/get_statuses` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh statuses` | Returns 8 statuses, including `Automation Passed`, `Automation Failed`, and `Automation Error`. |
| `/get_case_fields` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh case_fields` | Returns 12 case field definitions; confirms `custom_steps` is markdown text and `custom_steps_separated` is structured steps. |
| `/get_priorities` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh priorities` | Returns 4 priorities: Low, Medium, High, Critical. |
| `/get_case_types` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh case_types` | Returns 12 case types, including Automated, Regression, and Security. |
| `/get_templates/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh templates 1` | Verified project 1; returns 5 templates as a raw array. |
| `/get_result_fields` | GET | ✅ **TESTED & WORKING** | `scripts/get_reference_data.sh result_fields` | Returns 6 result field definitions as a raw array. |

---

## Attachments

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/add_attachment_to_case/:case_id` | POST | ✅ **TESTED & WORKING** | `scripts/add_attachment.sh case`, `examples/workflow_attachments.sh` | Uploaded attachment to disposable case 92; response returns `{attachment_id}`. |
| `/add_attachment_to_result/:result_id` | POST | ✅ **TESTED & WORKING** | `scripts/add_attachment.sh result`, `examples/workflow_attachments.sh` | Uploaded attachment to disposable result 107 and verified visibility via test attachment listing. |
| `/add_attachment_to_plan/:plan_id` | POST | ✅ **TESTED & WORKING** | `scripts/add_attachment.sh plan`, `examples/workflow_attachments.sh` | Uploaded attachment to disposable plan 58 successfully; response returns `{attachment_id}`. |
| `/add_attachment_to_plan_entry/:plan_id/:entry_id` | POST | ✅ **TESTED & WORKING** | `scripts/add_attachment.sh plan_entry`, `examples/workflow_attachments.sh` | Uploaded attachment to disposable plan entry `63754781-b44f-4de9-8869-41bc4a2d4ae3` successfully. |
| `/get_attachments_for_case/:case_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_attachments.sh case`, `examples/workflow_attachments.sh` | Returns a paginated object with `.attachments`; verified uploaded case attachment appears and disappears after delete. |
| `/get_attachments_for_test/:test_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_attachments.sh test`, `examples/workflow_attachments.sh` | Returns a raw array on this server; verified uploaded result attachment appears and disappears after delete. |
| `/delete_attachment/:attachment_id` | POST | ✅ **TESTED & WORKING** | `scripts/delete_attachment.sh`, `examples/workflow_attachments.sh` | Returns an empty success body; verified deletion by absence in follow-up case/test attachment listings. |

---

## Summary Statistics

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ TESTED & WORKING | 50 | 100% |
| 🔒 PERMISSION-GATED | 0 | 0% |
| ⚠️ SCRIPT EXISTS | 0 | 0% |
| 📝 NOT TESTED | 0 | 0% |
| ❌ KNOWN ISSUES | 0 | 0% |
| **TOTAL** | **50** | **100%** |

---

## Complete Workflow Test Results

### ✅ End-to-End CI Workflow (`examples/workflow_ci.sh`)

**Tested successfully on 2026-06-23:**

1. ✅ Create run → Run ID: 17
2. ✅ Get tests → Test IDs: [117, 118, 119]
3. ✅ Add results → 3 results added (2 passed, 1 failed)
4. ✅ Close run → Marked completed

**Endpoints used:**
- `POST /add_run/:project_id`
- `GET /get_tests/:run_id`
- `POST /add_results/:run_id`
- `POST /close_run/:run_id`

All worked without errors!

---

### ✅ Plans & Milestones Lifecycle (`examples/workflow_plans_milestones.sh`)

**Tested successfully on 2026-06-23:**

1. ✅ Create disposable milestone → verified with `get_milestones` and `get_milestone`
2. ✅ Update disposable milestone → confirmed updated `description` and `refs`
3. ✅ Create disposable plan with initial entry → verified with `get_plans` and `get_plan`
4. ✅ Add second plan entry and update it → validated selected case IDs with `get_tests`
5. ✅ Close plan → observed `is_completed=true`
6. ✅ Delete unclosed plan and milestone → verified both fixtures disappeared from list endpoints
7. ✅ Attempt to delete completed plan after `close_plan` → server returned HTTP 403 `You are not allowed to delete completed test plans (insufficient permissions)`

**Endpoints used directly in workflow:**
- `GET /get_plans/:project_id`
- `GET /get_plan/:id`
- `POST /add_plan/:project_id`
- `POST /add_plan_entry/:plan_id`
- `POST /update_plan/:id`
- `POST /update_plan_entry/:plan_id/:entry_id`
- `POST /close_plan/:id`
- `POST /delete_plan/:id`
- `GET /get_milestones/:project_id`
- `GET /get_milestone/:id`
- `POST /add_milestone/:project_id`
- `POST /update_milestone/:id`
- `POST /delete_milestone/:id`

**Observed API behavior:**
- `DELETE /delete_plan` works for disposable unclosed plans, but this server/user cannot delete completed plans after `close_plan` (HTTP 403 `insufficient permissions`).
- Plan and plan-entry responses did not echo `case_ids` for generated runs on this server; the workflow verified case selection with `GET /get_tests/:run_id` instead.

---

## Priority Recommendations for Testing

### High Priority (Maintenance follow-up)
1. Re-run attachment flows after server upgrades or storage/backend changes
2. Add alternate-project coverage if a multi-project test server becomes available
3. Re-check completed-plan and completed-run deletion permissions with a higher-privilege account

### Medium Priority (Broader validation)
4. Non-admin account verification for permission-sensitive endpoints
5. Cross-project template/field drift checks on non-sample projects
6. Regression re-run after any custom-field configuration changes

### Low Priority (Operational hardening)
7. Optional CI smoke job for the workflow examples
8. Periodic audit of API response shape drift

---

## Known Working Configuration

**Environment:**
- TestRail URL: `https://sudzilouski.testrail.io`
- API: Enabled ✅
- Project ID: 1 ("Sample Project")
- Suite ID: 1 ("Master")
- Test Cases: live count intentionally omitted; use `scripts/count_cases.sh` for the current total

**Working Scripts:**
- ✅ `scripts/get_cases.sh`
- ✅ `scripts/count_cases.sh`
- ✅ `scripts/delete_case.sh`
- ✅ `scripts/doctor.sh`
- ✅ `scripts/get_projects.sh`
- ✅ `scripts/get_project.sh`
- ✅ `scripts/get_sections.sh`
- ✅ `scripts/get_case.sh`
- ✅ `scripts/get_runs.sh`
- ✅ `scripts/get_test.sh`
- ✅ `scripts/get_results.sh`
- ✅ `scripts/get_results_for_case.sh`
- ✅ `scripts/get_results_for_run.sh`
- ✅ `scripts/get_reference_data.sh`
- ✅ `scripts/import_cases.sh`
- ✅ `scripts/create_run.sh`
- ✅ `scripts/close_run.sh`
- ✅ `scripts/bulk_results.sh`
- ✅ `scripts/add_result.sh`
- ✅ `scripts/add_result_for_case.sh`
- ✅ `scripts/get_plans.sh`
- ✅ `scripts/get_milestones.sh`
- ✅ `scripts/update_case.sh`
- ✅ `scripts/update_run.sh`
- ✅ `scripts/add_attachment.sh`
- ✅ `scripts/get_attachments.sh`
- ✅ `scripts/delete_attachment.sh`
- ✅ `examples/workflow_ci.sh`
- ✅ `examples/create_case.sh`
- ✅ `examples/workflow_plans_milestones.sh`
- ✅ `examples/workflow_attachments.sh`

**Security:**
- Credentials isolated in `.env`
- LLM never sees API keys ✅
- Scripts load credentials internally ✅

---

## Next Steps

1. **Maintenance checks:**
   - Re-run disposable workflows after server permission/configuration changes
   - Confirm completed run/plan deletion with a higher-privilege account if available

2. **Documentation hygiene:**
   - Keep response-shape notes in `docs/api-reference.md` in sync with live behavior
   - Update script/example lists when new wrappers are added

---

**Last Updated:** 2026-06-24
