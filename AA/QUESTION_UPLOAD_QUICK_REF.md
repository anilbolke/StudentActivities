# Question Upload - Quick Reference

## File Format (Pipe-Delimited)
```
CLASS|SUBJECT|CHAPTER|QUESTION_TEXT|OPTION_A|OPTION_B|OPTION_C|OPTION_D|CORRECT_ANSWER|DIFFICULTY|MARKS
```

## Example
```
10|Mathematics|Algebra|What is 2+2?|3|4|5|6|B|Easy|1
11|Physics|Motion|SI unit of force?|Newton|Dyne|Joule|Watt|A|Medium|2
12|Chemistry|Organic|Formula for alkanes?|CnH2n+2|CnH2n|CnH2n-2|CnH3n|A|Hard|3
```

## Upload Endpoint
```
POST /api/admin/uploadQuestions
```

## Quick cURL Command
```bash
curl -X POST -F "file=@questions.txt" \
  -H "Cookie: JSESSIONID=your_session_id" \
  http://localhost:8080/StudentActivities/api/admin/uploadQuestions
```

## Validation Rules Checklist
- [ ] File is `.txt` format
- [ ] Uses pipe `|` as separator
- [ ] 11 fields per line
- [ ] CLASS exists in database (10, 11, 12, etc.)
- [ ] SUBJECT name is not empty
- [ ] CHAPTER name is not empty
- [ ] QUESTION_TEXT is not empty
- [ ] All 4 OPTIONS (A, B, C, D) are not empty
- [ ] CORRECT_ANSWER is A, B, C, or D
- [ ] DIFFICULTY is Easy, Medium, or Hard
- [ ] MARKS is 1-100

## Success Response
```json
{
  "status": "success",
  "message": "File uploaded successfully",
  "totalRecords": 100,
  "successCount": 98,
  "failureCount": 2,
  "successPercentage": 98.0
}
```

## Common Errors
| Error | Cause | Fix |
|-------|-------|-----|
| "Correct answer must be A, B, C, or D" | Invalid value in CORRECT_ANSWER field | Use A, B, C, or D only |
| "Class 'X' not found" | Class doesn't exist | Ensure class exists in database |
| "Difficulty must be EASY, MEDIUM, or HARD" | Invalid difficulty value | Use Easy, Medium, or Hard |
| "Marks must be between 1 and 100" | Invalid marks | Set marks 1-100 |
| "Expected 11 fields" | Wrong number of fields | Use exactly 11 pipe-separated fields |

## Sample Files Location
- `sample-questions.txt` - Valid example with 36 questions
- `sample-questions-with-errors.txt` - Example with various errors for testing

## Database Impact
- Creates/links Classes, Subjects, Chapters (Topics) as needed
- Inserts Questions with 4 options each
- Auto-creates missing Subjects and Topics
- No data deleted or modified - pure insert operation
