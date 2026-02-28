const fs = require("fs");
const path = require("path");

const allowedUtility = new Set(["high", "medium", "low"]);
const allowedRule = new Set(["pass", "fail", ""]);

function parseCsvLine(line) {
  const values = [];
  let current = "";
  let inQuotes = false;

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    const next = line[index + 1];

    if (char === '"') {
      if (inQuotes && next === '"') {
        current += '"';
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === "," && !inQuotes) {
      values.push(current);
      current = "";
      continue;
    }

    current += char;
  }

  values.push(current);
  return values.map((value) => String(value || "").trim());
}

function parseCsv(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  const normalized = content.replace(/^\uFEFF/, "").replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  const lines = normalized
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0);

  if (lines.length < 2) {
    return [];
  }

  const headers = parseCsvLine(lines[0]);
  const rows = [];

  for (let i = 1; i < lines.length; i += 1) {
    const values = parseCsvLine(lines[i]);
    const row = {};

    headers.forEach((header, idx) => {
      row[header] = values[idx] ?? "";
    });

    row.__line = i + 1;
    rows.push(row);
  }

  return rows;
}

function asInt(value) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed)) return null;
  return parsed;
}

function validateDayPlan(rows) {
  const errors = [];
  const dayKeys = new Set();

  rows.forEach((row) => {
    const trackName = String(row.track_name || "").trim();
    const dayNo = asInt(row.day_no);

    if (!trackName) {
      errors.push(`[day_plan:L${row.__line}] track_name is required`);
    }
    if (!dayNo || dayNo < 1 || dayNo > 365) {
      errors.push(`[day_plan:L${row.__line}] day_no must be 1..365`);
    }

    if (trackName && dayNo) {
      const key = `${trackName}:${dayNo}`;
      if (dayKeys.has(key)) {
        errors.push(`[day_plan:L${row.__line}] duplicate day key: ${key}`);
      }
      dayKeys.add(key);
    }
  });

  return { errors, dayKeys };
}

function validateDayItems(rows, dayKeys) {
  const strictMode = process.argv.includes("--strict");
  const errors = [];
  const warnings = [];
  const daySortMap = new Map();
  const dayCountMap = new Map();
  let blankRows = 0;
  let filledRows = 0;

  rows.forEach((row) => {
    const trackName = String(row.track_name || "").trim();
    const dayNo = asInt(row.day_no);
    const sortNo = asInt(row.sort_no);
    const headword = String(row.headword || "").trim();
    const pos = String(row.pos || "").trim();

    const isCompletelyBlankWordRow = !headword && !pos;
    if (isCompletelyBlankWordRow) {
      blankRows += 1;
      return;
    }

    filledRows += 1;

    const dayKey = trackName && dayNo ? `${trackName}:${dayNo}` : null;

    if (!trackName) errors.push(`[day_items:L${row.__line}] track_name is required`);
    if (!dayNo || dayNo < 1 || dayNo > 365) errors.push(`[day_items:L${row.__line}] day_no must be 1..365`);
    if (!sortNo || sortNo < 1 || sortNo > 10) errors.push(`[day_items:L${row.__line}] sort_no must be 1..10`);
    if (!headword) errors.push(`[day_items:L${row.__line}] headword is required`);
    if (!pos) errors.push(`[day_items:L${row.__line}] pos is required`);

    if (dayKey && !dayKeys.has(dayKey)) {
      errors.push(`[day_items:L${row.__line}] missing day_plan row for ${dayKey}`);
    }

    if (dayKey && sortNo) {
      if (!daySortMap.has(dayKey)) daySortMap.set(dayKey, new Set());
      const sortSet = daySortMap.get(dayKey);
      if (sortSet.has(sortNo)) {
        errors.push(`[day_items:L${row.__line}] duplicate sort_no ${sortNo} in ${dayKey}`);
      }
      sortSet.add(sortNo);

      dayCountMap.set(dayKey, (dayCountMap.get(dayKey) || 0) + 1);
    }

    const utility = String(row["utility_priority(high|medium|low)"] || "").trim().toLowerCase();
    if (utility && !allowedUtility.has(utility)) {
      errors.push(`[day_items:L${row.__line}] utility_priority must be high|medium|low`);
    }

    [
      "rule_frequency(pass|fail)",
      "rule_utility(pass|fail)",
      "rule_core_meaning(pass|fail)",
      "rule_collocation(pass|fail)",
      "rule_word_family(pass|fail)",
      "rule_confusion_risk(pass|fail)",
    ].forEach((key) => {
      const value = String(row[key] || "").trim().toLowerCase();
      if (!allowedRule.has(value)) {
        errors.push(`[day_items:L${row.__line}] ${key} must be pass|fail or blank`);
      }
    });

    const coreMeaning = String(row.core_meaning_en || "").trim();
    const collocation = String(row.collocation_1 || "").trim();
    const exampleSentence = String(row.example_sentence_1 || "").trim();
    const ipaUs = String(row.ipa_us || "").trim();
    const ipaUk = String(row.ipa_uk || "").trim();

    if (!coreMeaning) {
      const msg = `[day_items:L${row.__line}] core_meaning_en is blank`;
      strictMode ? errors.push(msg) : warnings.push(msg);
    }
    if (!collocation) {
      const msg = `[day_items:L${row.__line}] collocation_1 is blank`;
      strictMode ? errors.push(msg) : warnings.push(msg);
    }
    if (!exampleSentence) {
      const msg = `[day_items:L${row.__line}] example_sentence_1 is blank`;
      strictMode ? errors.push(msg) : warnings.push(msg);
    }
    if (!ipaUs && !ipaUk) {
      const msg = `[day_items:L${row.__line}] either ipa_us or ipa_uk is required`;
      strictMode ? errors.push(msg) : warnings.push(msg);
    }
  });

  for (const [dayKey, count] of dayCountMap.entries()) {
    if (count !== 10) {
      const msg = `[day_items] ${dayKey} has ${count} rows (recommended: 10)`;
      strictMode ? errors.push(msg) : warnings.push(msg);
    }
  }

  if (blankRows > 0) {
    warnings.push(`[day_items] blank template rows skipped: ${blankRows}`);
  }

  if (strictMode && filledRows === 0) {
    errors.push("[day_items] strict mode requires at least one filled word row");
  }

  return { errors, warnings };
}

function run() {
  const args = process.argv.slice(2);
  const positionalArgs = args.filter((arg) => !arg.startsWith("--"));

  const dayPlanPath = positionalArgs[0]
    ? path.resolve(positionalArgs[0])
    : path.resolve("wordbook_templates/day_plan_2_30.csv");
  const dayItemsPath = positionalArgs[1]
    ? path.resolve(positionalArgs[1])
    : path.resolve("wordbook_templates/day_items_2_30.csv");

  if (!fs.existsSync(dayPlanPath)) {
    console.error(`File not found: ${dayPlanPath}`);
    process.exit(1);
  }
  if (!fs.existsSync(dayItemsPath)) {
    console.error(`File not found: ${dayItemsPath}`);
    process.exit(1);
  }

  const dayPlanRows = parseCsv(dayPlanPath);
  const dayItemRows = parseCsv(dayItemsPath);

  const dayPlanResult = validateDayPlan(dayPlanRows);
  const dayItemsResult = validateDayItems(dayItemRows, dayPlanResult.dayKeys);

  const errors = [...dayPlanResult.errors, ...dayItemsResult.errors];
  const warnings = [...dayItemsResult.warnings];

  console.log(`Checked day_plan rows: ${dayPlanRows.length}`);
  console.log(`Checked day_items rows: ${dayItemRows.length}`);
  console.log(`Errors: ${errors.length}`);
  console.log(`Warnings: ${warnings.length}`);

  if (errors.length > 0) {
    console.log("\n[ERROR LIST]");
    errors.slice(0, 200).forEach((error) => console.log(error));
  }

  if (warnings.length > 0) {
    console.log("\n[WARNING LIST]");
    warnings.slice(0, 200).forEach((warning) => console.log(warning));
  }

  if (errors.length > 0) {
    process.exit(1);
  }

  console.log("\nValidation passed ✅");
}

run();
