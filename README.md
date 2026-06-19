# FAB Investigation Portal

Interactive fraud & abuse investigation portal for the ODSP FAB team.

## Quick Start

Visit the portal: **[fab-investigations](https://varunvaithy.github.io/fab-investigations/docs/portal.html)**

## What's Inside

| Section | Description |
|---|---|
| **Investigations** | 32 fraud ring analyses, EDU abuse investigations, storage abuse cases |
| **Data Explorer** | Interactive CSV viewer with sort, filter, pagination, export |
| **Query Library** | Production KQL & SQL queries with copy-to-clipboard |
| **Dashboard** | Biweekly FAB performance metrics |

## Adding a New Investigation

1. Drop your `.md` report in `docs/investigations/`
2. Add an entry to `docs/assets/manifest.js` in the `INVESTIGATIONS` array:

```js
{
  id: "inv-XXX",
  title: "Your Investigation Title",
  file: "investigations/Your_Report.md",
  date: "2026-06-19",        // Investigation date (YYYY-MM-DD)
  status: "active",           // active|pending|completed|remediated
  category: "ring-analysis",  // ring-analysis|edu-fraud|storage-abuse|detection-rules|...
  summary: "One-line summary shown on cards.",
  tenants: 42,
  storage: "100 TB",
  severity: "critical",       // critical|high|medium|low
  tags: ["tag1", "tag2"]
}
```

3. Commit and push — GitHub Pages deploys automatically.

## Adding New Data Files

1. Add your `.csv` to `docs/` or a subfolder
2. Add an entry to the `DATA_FILES` array in `docs/assets/manifest.js`
3. It'll show up in the Data Explorer immediately

## Local Preview

```bash
npx http-server docs -p 3456 --cors
# Open http://localhost:3456/portal.html
```
