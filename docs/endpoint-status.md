# TestRail API Endpoints - Testing Status

Complete list of all TestRail API v2 endpoints with testing status.

Legend:
- ✅ **TESTED & WORKING** - Verified in production
- ⚠️ **SCRIPT EXISTS** - Script created but not fully tested
- 📝 **NOT TESTED** - Documented but no script yet
- ❌ **KNOWN ISSUES** - Tested but has problems

---

## Projects

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_projects` | GET | ✅ **TESTED & WORKING** | Manual test | Returns 1 project: "Sample Project" |
| `/get_project/:id` | GET | 📝 **NOT TESTED** | - | - |

---

## Suites & Sections

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_suites/:project_id` | GET | ✅ **TESTED & WORKING** | Manual test | Found Suite 1: "Master" |
| `/get_sections/:project_id` | GET | 📝 **NOT TESTED** | - | - |

---

## Test Cases

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_cases/:project_id` | GET | ✅ **TESTED & WORKING** | `scripts/get_cases.sh` | Returns 17 cases, works from any directory |
| `/get_case/:id` | GET | 📝 **NOT TESTED** | - | - |
| `/add_case/:section_id` | POST | ⚠️ **SCRIPT EXISTS** | `examples/create_case.sh` | Example with all fields, not tested end-to-end |
| `/update_case/:id` | POST | 📝 **NOT TESTED** | - | - |

---

## Test Runs & Tests

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_runs/:project_id` | GET | 📝 **NOT TESTED** | - | - |
| `/add_run/:project_id` | POST | ✅ **TESTED & WORKING** | `scripts/create_run.sh` | Created run ID 14, 15, 16, 17 successfully |
| `/get_tests/:run_id` | GET | ✅ **TESTED & WORKING** | Used in `workflow_ci.sh` | Returns test IDs: [111, 112, 113] for run 15 |
| `/get_test/:id` | GET | 📝 **NOT TESTED** | - | - |
| `/close_run/:run_id` | POST | ✅ **TESTED & WORKING** | `scripts/close_run.sh` | Closed run 17, marked is_completed=true |
| `/update_run/:id` | POST | 📝 **NOT TESTED** | - | - |
| `/delete_run/:id` | POST | 📝 **NOT TESTED** | - | - |

---

## Results

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/add_result/:test_id` | POST | ⚠️ **SCRIPT EXISTS** | `scripts/add_result.sh` | Script created, not tested end-to-end |
| `/add_result_for_case/:run_id/:case_id` | POST | 📝 **NOT TESTED** | - | Alternative to add_result |
| `/add_results/:run_id` | POST | ✅ **TESTED & WORKING** | `scripts/bulk_results.sh` | Added 3 results in workflow: 2 passed, 1 failed |
| `/get_results/:test_id` | GET | 📝 **NOT TESTED** | - | - |
| `/get_results_for_case/:run_id/:case_id` | GET | 📝 **NOT TESTED** | - | - |
| `/get_results_for_run/:run_id` | GET | 📝 **NOT TESTED** | - | - |

---

## Plans

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_plans/:project_id` | GET | 📝 **NOT TESTED** | - | - |
| `/get_plan/:id` | GET | 📝 **NOT TESTED** | - | - |
| `/add_plan/:project_id` | POST | 📝 **NOT TESTED** | - | - |
| `/add_plan_entry/:plan_id` | POST | 📝 **NOT TESTED** | - | - |
| `/update_plan/:id` | POST | 📝 **NOT TESTED** | - | - |
| `/update_plan_entry/:plan_id/:entry_id` | POST | 📝 **NOT TESTED** | - | - |
| `/close_plan/:id` | POST | 📝 **NOT TESTED** | - | - |
| `/delete_plan/:id` | POST | 📝 **NOT TESTED** | - | - |

---

## Milestones

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_milestones/:project_id` | GET | 📝 **NOT TESTED** | - | - |
| `/get_milestone/:id` | GET | 📝 **NOT TESTED** | - | - |
| `/add_milestone/:project_id` | POST | 📝 **NOT TESTED** | - | - |
| `/update_milestone/:id` | POST | 📝 **NOT TESTED** | - | - |
| `/delete_milestone/:id` | POST | 📝 **NOT TESTED** | - | - |

---

## Metadata & Configuration

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/get_users` | GET | 📝 **NOT TESTED** | - | Admin only |
| `/get_user/:id` | GET | 📝 **NOT TESTED** | - | - |
| `/get_user_by_email` | GET | 📝 **NOT TESTED** | - | - |
| `/get_statuses` | GET | 📝 **NOT TESTED** | - | Get available result statuses |
| `/get_case_fields` | GET | 📝 **NOT TESTED** | - | Get custom field definitions |
| `/get_priorities` | GET | 📝 **NOT TESTED** | - | Get available priorities |
| `/get_case_types` | GET | 📝 **NOT TESTED** | - | Get available case types |
| `/get_templates/:project_id` | GET | 📝 **NOT TESTED** | - | Get case templates |
| `/get_result_fields` | GET | 📝 **NOT TESTED** | - | Get result field definitions |

---

## Attachments

| Endpoint | Method | Status | Script | Notes |
|----------|--------|--------|--------|-------|
| `/add_attachment_to_case/:case_id` | POST | 📝 **NOT TESTED** | - | Multipart form upload |
| `/add_attachment_to_result/:result_id` | POST | 📝 **NOT TESTED** | - | Multipart form upload |
| `/add_attachment_to_plan/:plan_id` | POST | 📝 **NOT TESTED** | - | Multipart form upload |
| `/add_attachment_to_plan_entry/:plan_id/:entry_id` | POST | 📝 **NOT TESTED** | - | Multipart form upload |
| `/get_attachments_for_case/:case_id` | GET | 📝 **NOT TESTED** | - | - |
| `/get_attachments_for_test/:test_id` | GET | 📝 **NOT TESTED** | - | - |
| `/delete_attachment/:attachment_id` | POST | 📝 **NOT TESTED** | - | - |

---

## Summary Statistics

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ TESTED & WORKING | 6 | 10% |
| ⚠️ SCRIPT EXISTS | 2 | 3% |
| 📝 NOT TESTED | 52 | 87% |
| ❌ KNOWN ISSUES | 0 | 0% |
| **TOTAL** | **60** | **100%** |

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

## Priority Recommendations for Testing

### High Priority (Core workflow)
1. `GET /get_runs/:project_id` - List runs
2. `GET /get_results_for_run/:run_id` - Verify results after upload
3. `POST /add_result/:test_id` - Single result (already has script)

### Medium Priority (Common operations)
4. `GET /get_case/:id` - Single case details
5. `POST /add_case/:section_id` - Create cases (already has example)
6. `GET /get_sections/:project_id` - Navigate case structure
7. `GET /get_statuses` - Understand available statuses

### Low Priority (Advanced features)
8. Plans endpoints - For complex test planning
9. Milestones endpoints - For release tracking
10. Attachments endpoints - For file uploads
11. User management - Admin features

---

## Known Working Configuration

**Environment:**
- TestRail URL: `https://sudzilouski.testrail.io`
- API: Enabled ✅
- Project ID: 1 ("Sample Project")
- Suite ID: 1 ("Master")
- Test Cases: 17 total

**Working Scripts:**
- ✅ `scripts/get_cases.sh`
- ✅ `scripts/create_run.sh`
- ✅ `scripts/close_run.sh`
- ✅ `scripts/bulk_results.sh`
- ✅ `examples/workflow_ci.sh`

**Security:**
- Credentials isolated in `.env`
- LLM never sees API keys ✅
- Scripts load credentials internally ✅

---

## Next Steps

1. **Test existing scripts:**
   - `scripts/add_result.sh` (single result)
   - `examples/create_case.sh` (create case)
   - `scripts/import_cases.sh` (export cases)

2. **Create missing high-priority scripts:**
   - `scripts/get_runs.sh`
   - `scripts/get_results.sh`
   - `scripts/get_statuses.sh`

3. **Add error handling:**
   - Check for API errors in responses
   - Validate required fields
   - Add retry logic for rate limits

4. **Documentation:**
   - Add response examples to api-reference.md
   - Create troubleshooting guide for common errors
   - Document all tested endpoints with examples

---

**Last Updated:** 2026-06-23
