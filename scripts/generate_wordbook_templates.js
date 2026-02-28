const fs = require("fs");
const path = require("path");

function parseNumber(value, fallback) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) return fallback;
  return parsed;
}

const startDay = parseNumber(process.argv[2], 2);
const endDay = parseNumber(process.argv[3], 30);

if (endDay < startDay) {
  console.error("endDay must be greater than or equal to startDay");
  process.exit(1);
}

const outputDir = path.join(process.cwd(), "wordbook_templates");
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const dayPlanPath = path.join(outputDir, `day_plan_${startDay}_${endDay}.csv`);
const dayItemsPath = path.join(outputDir, `day_items_${startDay}_${endDay}.csv`);

const dayPlanHeaders = [
  "track_name",
  "day_no",
  "theme",
  "cefr_tag",
  "actfl_tag",
  "notes",
];

const dayItemHeaders = [
  "track_name",
  "day_no",
  "sort_no",
  "headword",
  "pos",
  "ipa_us",
  "ipa_uk",
  "core_meaning_en",
  "core_meaning_ko",
  "cefr_tag",
  "actfl_tag",
  "utility_priority(high|medium|low)",
  "collocation_1",
  "example_sentence_1",
  "example_sentence_ko_1",
  "derivative_1_word",
  "derivative_1_pos",
  "derivative_2_word",
  "derivative_2_pos",
  "derivative_3_word",
  "derivative_3_pos",
  "rule_frequency(pass|fail)",
  "rule_utility(pass|fail)",
  "rule_core_meaning(pass|fail)",
  "rule_collocation(pass|fail)",
  "rule_word_family(pass|fail)",
  "rule_confusion_risk(pass|fail)",
  "reviewer_note",
  "confusion_pair_word(optional)",
  "confusion_pair_reason(optional)",
];

const dayPlanRows = [dayPlanHeaders.join(",")];
for (let day = startDay; day <= endDay; day += 1) {
  dayPlanRows.push(
    [
      "HighSchool_1_365_Bridge",
      day,
      `Day ${day} theme`,
      "B1",
      "Intermediate Mid",
      "10 words/day fixed",
    ].join(",")
  );
}

const dayItemRows = [dayItemHeaders.join(",")];
for (let day = startDay; day <= endDay; day += 1) {
  for (let sortNo = 1; sortNo <= 10; sortNo += 1) {
    dayItemRows.push(
      [
        "HighSchool_1_365_Bridge",
        day,
        sortNo,
        "",
        "",
        "",
        "",
        "",
        "",
        "B1",
        "Intermediate Mid",
        "high",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "pass",
        "pass",
        "pass",
        "pass",
        "pass",
        "pass",
        "",
        "",
        "",
      ].join(",")
    );
  }
}

fs.writeFileSync(dayPlanPath, dayPlanRows.join("\n"), "utf8");
fs.writeFileSync(dayItemsPath, dayItemRows.join("\n"), "utf8");

console.log(`Created: ${path.relative(process.cwd(), dayPlanPath)}`);
console.log(`Created: ${path.relative(process.cwd(), dayItemsPath)}`);
console.log(`Rows(day_items): ${(endDay - startDay + 1) * 10}`);
